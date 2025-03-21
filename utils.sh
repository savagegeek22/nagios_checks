#! /bin/sh

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

print_revision() {
	echo "$1 v$2 (nagios-plugins 2.4.9)"
	printf '%b' "The nagios plugins come with ABSOLUTELY NO WARRANTY. You may redistribute\ncopies of the plugins under the terms of the GNU General Public License.\nFor more information about these matters, see the file named COPYING.\n"
}

support() {
	printf '%b' "Send email to help@nagios-plugins.org if you have questions regarding use\nof this software. To submit patches or suggest improvements, send email to\ndevel@nagios-plugins.org. Please include version information with all\ncorrespondence (when possible, use output from the --version option of the\nplugin itself).\n"
}

#
# check_range takes a value and a range string, returning successfully if an
# alert should be raised based on the range.  Range values are inclusive.
# Values may be integers or floats.
#
# Example usage:
#
# Generating an exit code of 1:
# check_range 5 2:8
#
# Generating an exit code of 0:
# check_range 1 2:8
#
check_range() {
	local v range yes no err decimal start end cmp match
	v="$1"
	range="$2"

	# whether to raise an alert or not
	yes=0
	no=1
	err=2

	# regex to match a decimal number
	decimal="-?([0-9]+\.?[0-9]*|[0-9]*\.[0-9]+)"

	# compare numbers (including decimals), returning true/false
	cmp() { awk "BEGIN{ if ($1) exit(0); exit(1)}"; }

	# returns successfully if the string in the first argument matches the
	# regex in the second
	match() { echo "$1" | grep -E -q -- "$2"; }

	# make sure value is valid
	if ! match "$v" "^$decimal$"; then
		echo "${0##*/}: check_range: invalid value" >&2
		unset -f cmp match
		return "$err"
	fi

	# make sure range is valid
	if ! match "$range" "^@?(~|$decimal)(:($decimal)?)?$"; then
		echo "${0##*/}: check_range: invalid range" >&2
		unset -f cmp match
		return "$err"
	fi

	# check for leading @ char, which negates the range
	if match $range '^@'; then
		range=${range#@}
		yes=1
		no=0
	fi

	# parse the range string
	if ! match "$range" ':'; then
		start=0
		end="$range"
	else
		start="${range%%:*}"
		end="${range#*:}"
	fi

	# do the comparison, taking positive ("") and negative infinity ("~")
	# into account
	if [ "$start" != "~" ] && [ "$end" != "" ]; then
		if cmp "$start <= $v" && cmp "$v <= $end"; then
			unset -f cmp match
			return "$no"
		else
			unset -f cmp match
			return "$yes"
		fi
	elif [ "$start" != "~" ] && [ "$end" = "" ]; then
		if cmp "$start <= $v"; then
			unset -f cmp match
			return "$no"
		else
			unset -f cmp match
			return "$yes"
		fi
	elif [ "$start" = "~" ] && [ "$end" != "" ]; then
		if cmp "$v <= $end"; then
			unset -f cmp match
			return "$no"
		else
			unset -f cmp match
			return "$yes"
		fi
	else
		unset -f cmp match
		return "$no"
	fi
}
