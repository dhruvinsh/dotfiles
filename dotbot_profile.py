import os
from jinja2 import Environment, FileSystemLoader
from dotbot import Plugin

BLOCK_START = '{%@@'
BLOCK_END = '@@%}'
VAR_START = '{{@@'
VAR_END = '@@}}'
COMMENT_START = '{#@@'
COMMENT_END = '@@#}'


class ProfileLink(Plugin):

    _directive = 'profile_link'

    def __init__(self, context, base='.'):
        super(ProfileLink, self).__init__(context=context)
        loader = FileSystemLoader(base.rstrip(os.sep))
        self.env = Environment(loader=loader,
                               trim_blocks=True, lstrip_blocks=True,
                               keep_trailing_newline=True,
                               block_start_string=BLOCK_START,
                               block_end_string=BLOCK_END,
                               variable_start_string=VAR_START,
                               variable_end_string=VAR_END,
                               comment_start_string=COMMENT_START,
                               comment_end_string=COMMENT_END)


    def can_handle(self, directive):
        return directive == self._directive

    def handle(self, directive, data):
        if directive != self._directive:
            raise ValueError('Profile Link cannot handle directive %s' % directive)
        return self._process_links(data)

    def _process_links(self, links):
        success = True
        defaults = self._context.defaults().get('profile_link', {})
        for destination, source in links.items():
            destination = os.path.expandvars(destination)
            profile = defaults.get('profile', False)
            create = defaults.get('create', False)
            force = defaults.get('force', False)
            relink = defaults.get('relink', False)

            if isinstance(source, dict):
                # extended config
                profile = source.get('profile', profile)
                create = source.get('create', create)
                force = source.get('force', force)
                relink = source.get('relink', relink)
                path = self._default_source(destination, source.get('path'))
            else:
                path = self._default_source(destination, source)

            path = os.path.expandvars(os.path.expanduser(path))

            if create:
                success &= self._create(destination)

            if not self._exists(os.path.join(self._context.base_directory(), path)):
                success = False
                self._log.warning('Nonexistent source %s -> %s' %
                    (destination, path))
                continue
            if force or relink:
                success &= self._delete(path, destination, force)

            path = self._render(path, profile=profile)
            success &= self._link(path, destination)

            if not profile:
                self._log.warning("Globbing couldn't find anything matching " + str(path))
                success = False
                continue

            print(destination, source, profile)
        return success

    def _default_source(self, destination, source):
        if source is None:
            basename = os.path.basename(destination)
            if basename.startswith('.'):
                return basename[1:]
            else:
                return basename
        else:
            return source

    def _create(self, path):
        success = True
        parent = os.path.abspath(os.path.join(os.path.expanduser(path), os.pardir))
        if not self._exists(parent):
            self._log.debug("Try to create parent: " + str(parent))
            try:
                os.makedirs(parent)
            except OSError:
                self._log.warning('Failed to create directory %s' % parent)
                success = False
            else:
                self._log.lowinfo('Creating directory %s' % parent)
        return success

    def _delete(self, source, path, force):
        success = True
        source = os.path.join(self._context.base_directory(), source)
        fullpath = os.path.expanduser(path)
        if ((self._is_link(path) and self._link_destination(path) != source) or
                (self._exists(path) and not self._is_link(path))):
            removed = False
            try:
                if os.path.islink(fullpath):
                    os.unlink(fullpath)
                    removed = True
                elif force:
                    if os.path.isdir(fullpath):
                        shutil.rmtree(fullpath)
                        removed = True
                    else:
                        os.remove(fullpath)
                        removed = True
            except OSError:
                self._log.warning('Failed to remove %s' % path)
                success = False
            else:
                if removed:
                    self._log.lowinfo('Removing %s' % path)
        return success

    def _exists(self, path):
        '''
        Returns true if the path exists.
        '''
        path = os.path.expanduser(path)
        return os.path.exists(path)

    def _delete(self, source, path, force):
        success = True
        source = os.path.join(self._context.base_directory(), source)
        fullpath = os.path.expanduser(path)
        if ((self._is_link(path) and self._link_destination(path) != source) or
                (self._exists(path) and not self._is_link(path))):
            removed = False
            try:
                if os.path.islink(fullpath):
                    os.unlink(fullpath)
                    removed = True
                elif force:
                    if os.path.isdir(fullpath):
                        shutil.rmtree(fullpath)
                        removed = True
                    else:
                        os.remove(fullpath)
                        removed = True
            except OSError:
                self._log.warning('Failed to remove %s' % path)
                success = False
            else:
                if removed:
                    self._log.lowinfo('Removing %s' % path)
        return success

    def _link(self, absolute_source, link_name):
        '''
        Links link_name to source.

        Returns true if successfully linked files.
        '''
        success = False
        destination = os.path.expanduser(link_name)
        source = absolute_source
        if (not self._exists(link_name) and self._is_link(link_name) and
                self._link_destination(link_name) != source):
            self._log.warning('Invalid link %s -> %s' %
                (link_name, self._link_destination(link_name)))
        # we need to use absolute_source below because our cwd is the dotfiles
        # directory, and if source is relative, it will be relative to the
        # destination directory
        elif not self._exists(link_name) and self._exists(absolute_source):
            try:
                os.symlink(source, destination)
            except OSError:
                self._log.warning('Linking failed %s -> %s' % (link_name, source))
            else:
                self._log.lowinfo('Creating link %s -> %s' % (link_name, source))
                success = True
        elif self._exists(link_name) and not self._is_link(link_name):
            self._log.warning(
                '%s already exists but is a regular file or directory' %
                link_name)
        elif self._is_link(link_name) and self._link_destination(link_name) != source:
            self._log.warning('Incorrect link %s -> %s' %
                (link_name, self._link_destination(link_name)))
        # again, we use absolute_source to check for existence
        elif not self._exists(absolute_source):
            if self._is_link(link_name):
                self._log.warning('Nonexistent source %s -> %s' %
                    (link_name, source))
            else:
                self._log.warning('Nonexistent source for %s : %s' %
                    (link_name, source))
        else:
            self._log.lowinfo('Link exists %s -> %s' % (link_name, source))
            success = True
        return success

    def _render(self, source, **kwargs):
        absolute_source = os.path.join(self._context.base_directory(), source)
        parent_dir = os.path.abspath(os.path.join(absolute_source, os.pardir))
        template_dir = os.path.join(parent_dir, '_jinja_render')
        rendered_file = os.path.join(template_dir, os.path.basename(absolute_source))

        if not os.path.isdir(template_dir):
            os.mkdir(template_dir)

        template = self.env.get_template(source, parent=parent_dir)
        with open(rendered_file, 'w') as fp:
            fp.write(template.render(**kwargs))

        return rendered_file

    def _is_link(self, path):
        '''
        Returns true if the path is a symbolic link.
        '''
        return os.path.islink(os.path.expanduser(path))

    def _link_destination(self, path):
        '''
        Returns the destination of the symbolic link.
        '''
        path = os.path.expanduser(path)
        return os.readlink(path)
