# from https://chatgpt.com/share/67067d4c-67ac-8006-b219-7526d0412ed1
from difflib import get_close_matches
from typing import Dict, Tuple


def hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def color_distance(rgb1: Tuple[int, int, int], rgb2: Tuple[int, int, int]) -> float:
    return sum((c1 - c2) ** 2 for c1, c2 in zip(rgb1, rgb2)) ** 0.5


def closest_match(catppuccin: Dict[str, str], onedark: Dict[str, str]) -> list:
    result = []
    used_onedark_keys = set()
    for cat_name, cat_hex in catppuccin.items():
        cat_rgb = hex_to_rgb(cat_hex)
        closest_color = None
        min_dist = float("inf")
        for one_name, one_hex in onedark.items():
            if one_name in used_onedark_keys:
                continue
            one_rgb = hex_to_rgb(one_hex)
            dist = color_distance(cat_rgb, one_rgb)
            if dist < min_dist:
                min_dist = dist
                closest_color = (one_name, one_hex)
        if closest_color:
            used_onedark_keys.add(closest_color[0])
            result.append(
                {
                    "catppuccin_name": cat_name,
                    "onedark_name": closest_color[0],
                    "onedark_color": closest_color[1],
                    "notes": "Closest match",
                }
            )
    return result


catppuccin_colors = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
}

onedark_colors = {
    "white": "#abb2bf",
    "darker_black": "#1b1f27",
    "black": "#1e222a",
    "black2": "#252931",
    "one_bg": "#282c34",
    "one_bg2": "#353b45",
    "one_bg3": "#373b43",
    "grey": "#42464e",
    "grey_fg": "#565c64",
    "grey_fg2": "#6f737b",
    "light_grey": "#6f737b",
    "red": "#e06c75",
    "baby_pink": "#DE8C92",
    "pink": "#ff75a0",
    "line": "#31353d",
    "green": "#98c379",
    "vibrant_green": "#7eca9c",
    "nord_blue": "#81A1C1",
    "blue": "#61afef",
    "yellow": "#e7c787",
    "sun": "#EBCB8B",
    "purple": "#de98fd",
    "dark_purple": "#c882e7",
    "teal": "#519ABA",
    "orange": "#fca2aa",
    "cyan": "#a3b8ef",
    "statusline_bg": "#22262e",
    "lightbg": "#2d3139",
    "pmenu_bg": "#61afef",
    "folder_bg": "#61afef",
}

print(closest_match(catppuccin_colors, onedark_colors))
