#!/bin/bash

set -e

if [ -z "$1" ]; then
	echo "Usage: ./get_linux_emial ./linux/"
	echo "Use \"git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git\" to get linux source code."
	exit
fi

linux_dir=$1

all_emails=$(mktemp /tmp/all-emails.XXXXXX)
email_domains=$(mktemp /tmp/email-domains.XXXXXX)
email_rank=$(mktemp /tmp/email-rank.XXXXXX)

pushd $linux_dir
echo "wroking...Please wait..."

git log | grep -E -o "<\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b>" | tr A-Z a-z | sort | uniq >$all_emails
cat $all_emails | cut -d "@" -f 2 | sort | uniq >$email_domains

cat /dev/null >$email_rank
cat $email_domains | while read line 
do
 	echo -n -e "$line\t" >>$email_rank
	grep -F -- "@$line" $all_emails | wc -l >>$email_rank
done

echo "Result:"
cat $email_rank | sort -k2 -n -r | head -n 10

rm $all_emails
rm $email_domains
rm $email_rank

popd
