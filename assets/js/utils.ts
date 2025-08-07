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

function ms(ms: number) {
    return {
        time: ms % 1000,
        remaining: Math.floor(ms / 1000),
        modifier: "ms",
    }
}

function s(s: number) {
    return {
        time: s % 60,
        remaining: Math.floor(s / 60),
        modifier: "s",
    }
}

function m(m: number) {
    return {
        time: m % 60,
        remaining: Math.floor(m / 60),
        modifier: "m",
    }
}

const time_formats = [ms, s, m];
export function relative_time(time_ms: number) {
    let time = { time: 0, remaining: time_ms, modifier: "" };
    for (const format of time_formats) {
        time = format(time.remaining);
        if (time.remaining == 0) {
            break;
        }
    }
    return `${time.time}${time.modifier}`;
}
