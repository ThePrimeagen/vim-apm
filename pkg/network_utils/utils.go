package networkutils

func ToInteger(s string) int {
    zero := int('0')
    value := int(s[0])

    return value - zero
}
