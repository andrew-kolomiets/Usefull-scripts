#!/bin/bash

# Download RSS feed
kyivpost_feed="https://www.kyivpost.com/feed"
kyivpost_xml=$(curl -s $kyivpost_feed)

# Extract text from <description> tags
kyivpost_description=$(echo "$kyivpost_xml" | xmlstarlet sel -t -v '//item/description' -n)

# Format text with line breaks
kyivpost_formatted=$(echo "$kyivpost_description" | sed -e 's/<[^>]*>//g; s/&lt;/</g; s/&gt;/>/g; s/\s\+/ /g; s/\s*$//g; s/^ *//g; s/<\/p>/\n\n/g')

# Create EPUB file with formatted text

date=$(date +%Y-%m-%d)
echo "$kyivpost_formatted" | sed G > kyivpost.txt

# Set the RSS feed URL
rss_url="https://feeds.a.dj.com/rss/RSSWorldNews.xml"

# Download the RSS feed and save it to a file
wget -q -O rss_feed.xml $rss_url

# Extract the text from the title and description tags and save it to a file
xmlstarlet sel -t -m "//item" -v "concat(title, ' ', description)" -n rss_feed.xml | sed G > extracted_text.txt

# Add author and date to metadata
metadata="author: ChatGPT\ndate: $date"
current_date=$(date +%Y-%m-%d_%H-%M-%S)


pandoc kyivpost.txt extracted_text.txt -o "news_${current_date}.epub" --metadata "author=ChatGPT" --metadata "title=News"


# Cleanup

cat kyivpost.txt
cat extracted_text.txt

rm kyivpost.txt
rm extracted_text.txt
rm rss_feed.xml


