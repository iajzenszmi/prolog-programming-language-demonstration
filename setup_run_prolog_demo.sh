#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Data dictionary
# ------------------------------------------------------------
# APP_NAME         : Name of the demo project directory
# DEMO_FILE        : Main Prolog source file
# RUN_FILE         : Helper shell script to run the demo
# USE_PPA          : If "yes", install SWI-Prolog from official PPA
#                    If "no", use distro package
# ============================================================

APP_NAME="prolog_demo"
DEMO_FILE="demo.pl"
RUN_FILE="run_demo.sh"
USE_PPA="yes"

echo "==> Preparing system dependencies"

sudo apt-get update
sudo apt-get install -y software-properties-common

if [ "$USE_PPA" = "yes" ]; then
    echo "==> Installing SWI-Prolog from official stable PPA"
    sudo apt-add-repository -y ppa:swi-prolog/stable
    sudo apt-get update
    sudo apt-get install -y swi-prolog
else
    echo "==> Installing SWI-Prolog from distro repository"
    sudo apt-get install -y swi-prolog
fi

echo "==> Creating demo project"
mkdir -p "$APP_NAME"
cd "$APP_NAME"

cat > "$DEMO_FILE" <<'PROLOG'
:- initialization(main).

/*
  Data dictionary
  ----------------
  hello/0         : prints greeting
  factorial/2     : computes factorial of non-negative integer N
  main/0          : entry point for non-interactive execution
*/

hello :-
    writeln('Hello from SWI-Prolog demo!').

factorial(0, 1).
factorial(N, F) :-
    N > 0,
    N1 is N - 1,
    factorial(N1, F1),
    F is N * F1.

main :-
    hello,
    factorial(5, F),
    format('factorial(5) = ~w~n', [F]),
    writeln('Demo finished successfully.'),
    halt.
PROLOG

cat > "$RUN_FILE" <<'SH'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v swipl >/dev/null 2>&1; then
    echo "Error: swipl not found in PATH"
    exit 1
fi

echo "Running Prolog demo..."
swipl demo.pl
SH

chmod +x "$RUN_FILE"

echo "==> Verifying installation"
swipl --version

echo "==> Running demo"
./"$RUN_FILE"

echo
echo "Project created in: $(pwd)"
echo "To run again later:"
echo "  cd $(pwd)"
echo "  ./$RUN_FILE"
