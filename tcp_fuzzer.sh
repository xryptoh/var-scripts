#!/bin/bash

usage() {
    echo "Usage: $0 -t <target> -p <port> -w <wordlist> [-T threads]"
    echo "  -t, --target    Target IP/hostname"
    echo "  -p, --port      Target port (default: 1234)"
    echo "  -w, --wordlist  Path to wordlist file"
    echo "  -T, --threads   Number of parallel threads (default: 10)"
    echo "  -h, --help      Show this help"
    exit 0
}

# Проверка на --help
if [ "$1" = "--help" ]; then
    usage
fi

TARGET=""
PORT=1234
WORDLIST=""
THREADS=10

while getopts "ht:p:w:T:" opt; do
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
        T)
            THREADS="$OPTARG"
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

[ -z "$TARGET" ] || [ -z "$WORDLIST" ] && { echo "Error: -t and -w are mandatory."; usage; }
[ ! -f "$WORDLIST" ] && { echo "Error: Wordlist file '$WORDLIST' not found."; exit 1; }
command -v nc >/dev/null 2>&1 || { echo "Error: 'nc' required."; exit 1; }

echo "=== TCP Fuzzer ==="
echo "Target: $TARGET:$PORT"
echo "Wordlist: $WORDLIST"
echo "Threads: $THREADS"
echo "====================="

test_line() {
    line="$1"
    echo "=== Testing: $line ==="
    echo "$line" | nc -w 1 "$TARGET" "$PORT" | head -c 500
    echo -e "\n\n---"
}
export -f test_line
export TARGET PORT

if command -v parallel >/dev/null 2>&1; then
    cat "$WORDLIST" | parallel -j "$THREADS" --line-buffer test_line {}
else
    echo "Warning: GNU parallel not found, using xargs (output may be garbled)."
    cat "$WORDLIST" | xargs -I{} -P "$THREADS" bash -c 'test_line "{}"'
fi
