#! /usr/bin/env ruby

require 'nokogiri'
require 'open-uri'
$total_count = 0
$pass_count = 0
$fail_count = 0
# $filename = "/Users/hiteshjain/Downloads/report_final_1.html"

def calculateTestCaseCount(filename)
  file = File.read(filename)
  doc = Nokogiri::HTML(file)
  testCaseNames = []
  doc.xpath('//h3[@class=\'title\']').each do |link|
    value = link.content
    if !(value.include? "BlibliMobile")
      if !(testCaseNames.include? value)
        testCaseNames.push(value)
        $total_count = $total_count + 1
      end
    end
  end
  doc.xpath('//h3[@class=\'time\']').each do |link|
    $pass_count = $pass_count + 1
  end
  $fail_count = $total_count - $pass_count
end

def showUpdatedTestCount(filename)
  doc = File.open(filename) { |f| Nokogiri::HTML(f) }
  h1 = doc.at_xpath "//*[@id=\"test-count\"]/span"
  h1.content = $total_count
  h1 = doc.at_xpath "//*[@id=\"fail-count\"]/span"
  h1.content = $fail_count
  File.write(filename,doc.to_html)
end

def addPieChart(filename)
  pieChart = "<section class=\"piechart\">
        <div id=\"piechart\" align=\"middle\" style=\"vertical-align: top;\"></div>
        <script type=\"text/javascript\" src=\"https://www.gstatic.com/charts/loader.js\"></script>
        <script type=\"text/javascript\">
        // Load google charts
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawChart);
        // Draw the chart and set the chart values
        function drawChart() {
          var data = google.visualization.arrayToDataTable([
          ['Result', 'Count'],
          ['Pass', $PASS_COUNT],
          ['Fail', $FAIL_COUNT]
        ]);
          // Optional; add a title and set the width and height of the chart
          var options = {'title':'Test Results', 'width':450, 'height':300 };
          // Display the chart inside the <div> element with id=\"piechart\"
          var chart = new google.visualization.PieChart(document.getElementById('piechart'));
          chart.draw(data, options);
        }
        </script>
        </section>"

  pieChart["$PASS_COUNT"] = $pass_count.to_s
  pieChart["$FAIL_COUNT"] = $fail_count.to_s
  doc = File.open(filename) { |f| Nokogiri::HTML(f) }
  addCss = doc.at_xpath "/html/head/style"
  contentOfCss = addCss.content + ".piechart {float: left; margin-left: 500px; margin-top: 68px; margin-right: 120px;}" + "rect {fill-opacity: 0.0 ;}"
  addCss.content = contentOfCss
  h1 = doc.at_xpath "/html/body/header"
  h1.add_next_sibling pieChart
  File.write(filename,doc.to_html)
end

# calculateTestCaseCount()
# showUpdatedTestCount()
# addPieChart()

if __FILE__ == $0
  filename = ARGV[0]
  calculateTestCaseCount(filename)
  showUpdatedTestCount(filename)
  addPieChart(filename)
end
