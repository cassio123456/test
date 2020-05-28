#!/usr/bin/env bash

export LC_ALL=C
TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
BUILDDIR=${BUILDDIR:-$TOPDIR}

BINDIR=${BINDIR:-$BUILDDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

BITCOINEVELIND=${BITCOIND:-$BINDIR/bitcoinevelind}
BITCOINEVELINCLI=${BITCOINCLI:-$BINDIR/bitcoinevelin-cli}
BITCOINEVELINTX=${BITCOINTX:-$BINDIR/bitcoinevelin-tx}
BITCOINEVELINQT=${BITCOINQT:-$BINDIR/qt/bitcoinevelin-qt}

[ ! -x $BITCOINEVELIND ] && echo "$BITCOINEVELIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
BTCevVER=($($BITCOINEVELINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$BITCOINEVELIND --version | sed -n '1!p' >> footer.h2m

for cmd in $BITCOINEVELIND $BITCOINEVELINCLI $BITCOINEVELINTX $BITCOINEVELINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${BTCevVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${BTCevVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
