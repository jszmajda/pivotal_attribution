Pivotal Attribution
===================

This is a simple reporting tool for Pivotal Tracker projects.
You need to download the CSV export from Pivotal Tracker and feed it into this script. You can get the CSV from your project by going to the "Actions" menu and select "Export CSV". Make sure all the checkboxes are checked and click "Export". You then feed this csv into the script as its first argument, a la:

    ./pivotal_attribution.rb <Your CSV File Here> <Optional Report Start Date>

for example:

    ./pivotal_attribution.rb my_awesome_project_20100803_1919.csv "Two Weeks Ago"

### Gems Required:

[FasterCSV](http://rubygems.org/gems/fastercsv), [Chronic](http://rubygems.org/gems/chronic), and [ActiveSupport](http://rubygems.org/gems/activesupport)

### Report Start Dates:

Can be anything [Chronic](http://rubygems.org/gems/chronic) accepts, like "Today", "Yesterday", "Two Months Ago", or "January 4th"

### Screenshots!

(Names changed to protect the innocent ;)

![pivotal_attribution](http://loki.ws/~josh/pivotal_attribution.png)

