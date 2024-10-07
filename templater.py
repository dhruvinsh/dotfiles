#!/usr/bin/env python3

"""Convert hex color code to catppuccin (for now) template."""

import argparse
import re
import sys

# Define the color scheme
color_scheme = {
    "#f5e0dc": "rosewater",
    "#f2cdcd": "flamingo",
    "#f5c2e7": "pink",
    "#cba6f7": "mauve",
    "#f38ba8": "red",
    "#eba0ac": "maroon",
    "#fab387": "peach",
    "#f9e2af": "yellow",
    "#a6e3a1": "green",
    "#94e2d5": "teal",
    "#89dceb": "sky",
    "#74c7ec": "sapphire",
    "#89b4fa": "blue",
    "#b4befe": "lavender",
    "#cdd6f4": "text",
    "#bac2de": "subtext1",
    "#a6adc8": "subtext0",
    "#9399b2": "overlay2",
    "#7f849c": "overlay1",
    "#6c7086": "overlay0",
    "#585b70": "surface2",
    "#45475a": "surface1",
    "#313244": "surface0",
    "#1e1e2e": "base",
    "#181825": "mantle",
    "#11111b": "crust",
    # custom codes,
    "#ffffff": "white",
}


def convert_hex_to_template(input_file: str, output_file: str, quote: bool) -> None:
    try:
        with open(input_file, "r") as file:
            data = file.read()

        # Find all hex color codes in the data
        hex_codes: list[str] = re.findall(r"#[0-9a-fA-F]{6}", data)

        for hex_code in hex_codes:
            if hex_code in color_scheme:
                if quote:
                    template = (
                        f"{{{{ .colorScheme.{color_scheme[hex_code]} | quote }}}}"
                    )
                    data = re.sub(rf'["\']?{hex_code}["\']?', template, data)
                else:
                    template = f"{{{{ .colorScheme.{color_scheme[hex_code]} }}}}"
                    data = data.replace(hex_code, template)
            else:
                raise ValueError(f"Hex code {hex_code} not found in color scheme")

        with open(output_file, "w") as file:
            _ = file.write(data)

        print("Conversion successful")

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Convert hex color codes to template format."
    )
    parser.add_argument("--input", help="The input file containing hex color codes.")
    parser.add_argument("--output", help="The output file to write the converted data.")
    parser.add_argument(
        "--quote",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Do not use | quote in the template.",
    )

    args = parser.parse_args()

    convert_hex_to_template(args.input, args.output, args.quote)
