const motion_display = {
    "": "PgUp",
    "": "PgDn",
}
function get_display_from_chars(chars: string) {
    if (motion_display[chars]) {
        return motion_display[chars];
    }
    return chars;
}

export function display_ui_motion(motion: UIMotion) {
    if (motion.count > 1) {
        return `${get_display_from_chars(motion.chars)}x${motion.count}`;
    }
    return get_display_from_chars(motion.chars);
}

export function set_text_class(element: HTMLElement, sizing: Map<number, string>, text: string) {
    for (const [_, class_name] of sizing) {
        element.classList.remove(class_name);
    }

    const sizes = Array.from(sizing.keys()).sort((a, b) => b - a);
    for (const size of sizes) {
        if (text.length >= size) {
            element.classList.add(sizing.get(size));
            break;
        }
    }
}
