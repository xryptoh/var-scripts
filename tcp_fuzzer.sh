#!/bin/bash

usage() {
    echo "Usage: $0 -t <target> -p <port> -w <wordlist>"
    echo "  -t, --target    Target IP/hostname"
    echo "  -p, --port      Target port ( default 1234 )"
    echo "  -w, --wordlist  Path to wordlist file"
    echo "  -h, --help      Show this help"
    exit 0
}

if [ "$1" = "--help" ]; then
    usage
fi

TARGET=""
PORT=1234
WORDLIST=""

# Разбор параметров
while getopts "ht:p:w:" opt; do
    case $opt in
        h)
            usage
            ;;
        t)
            TARGET="$OPTARG"
            ;;
        p)
            PORT="$OPTARG"
            ;;
        w)
            WORDLIST="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done

if [ -z "$TARGET" ] || [ -z "$WORDLIST" ]; then
    echo "Error: -t and -w are mandatory."
    usage
fi

if [ ! -f "$WORDLIST" ]; then
    echo "Error: Wordlist file '$WORDLIST' not found."
    exit 1
fi

if ! command -v nc >/dev/null 2>&1; then
    echo "Error: 'nc' (netcat) is required but not installed."
    exit 1
fi

echo "=== TCP Fuzzer ==="
echo "Target: $TARGET:$PORT"
echo "Wordlist: $WORDLIST"
echo "====================="

while IFS= read -r line; do
    echo "=== Testing: $line ==="
    echo "$line" | nc -w 1 "$TARGET" "$PORT" | head -c 500
    echo -e "\n\n\n---"
done < "$WORDLIST"
