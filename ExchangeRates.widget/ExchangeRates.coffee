###
Exchange Rates Widget for Übersicht
==================================
This Übersicht widget displays real-time exchange rates from multiple source currencies to a single target currency.

Features:

- Customizable source (`from_currencies`) and target (`to_currency`) currencies.
- Fetches data from Open Exchange Rates API.
- Automatically updates rates every hour.
- Displays the last update time.
###

command: ""

# Source currencies to display.
# Modify the `from_currencies` array to include currencies you wish to track.
from_currencies: ["USD", "GBP", "SGD", "EUR", "HKD", "JPY"]

# Target currency for conversion.
# Set your desired `to_currency`.
to_currency: "CNY"

# Your Open Exchange Rates API key.
# - Visit [Open Exchange Rates](https://openexchangerates.org) to sign up for a free account.
# - Obtain your `app_id` after registration.
app_id: "YOUR_APP_ID_HERE"  # Replace with your actual app_id.

# Flag to ensure data is loaded at least once.
dataLoaded: false

# Data refresh frequency (in milliseconds). Default is 1 minute.
refreshFrequency: 60 * 1000

# CSS styling for the widget.
style: """
  .exchange-rate-container
    position: absolute
    top: 29px
    left: 29px
    color: #fff
    font-family: 'Helvetica Neue'

  .exchange-rate-grid
    display: grid
    grid-template-columns: repeat(3, 1fr)
    grid-gap: 10px
    text-align: center

  .exchange-rate-widget
    background: rgba(0, 0, 0, 0.5)
    border: 1px solid white
    padding: 9px
    border-radius: 8px

  .exchange-rate-widget h3
    font-size: 17px
    margin: 4px 0
    font-weight: bold

  .exchange-rate-widget span
    font-size: 20px

  .last-update
    margin-top: 10px
    font-size: 12px
    text-align: left
"""

render: (input) ->
  html = '<div class="exchange-rate-container">'
  html += '<div class="exchange-rate-grid">'

  for from_currency in @from_currencies
    html += """
    <div class="exchange-rate-widget" id="widget-#{from_currency}-#{@to_currency}">
      <h3>#{from_currency}</h3>
      <span id='rate-#{from_currency}-#{@to_currency}'>--</span>
    </div>
    """

  html += '</div>'
  html += '<div class="last-update" id="last-update">Last update: --</div>'
  html += '</div>'
  return html

update: (input, domEl) ->
  currentTime = new Date()

  # Fetch new data at the top of the hour or if data hasn't been loaded yet.
  if currentTime.getMinutes() == 0 or not @dataLoaded
    self = @  # Preserve context.

    $.ajax
      dataType: "json"
      url: "https://openexchangerates.org/api/latest.json?app_id=#{@app_id}"
      success: (data) ->
        self.replaceRates(data)
        self.dataLoaded = true
      error: (xhr, status, error) ->
        console.error("Error fetching exchange rates:", error)
  else
    # Do not update if not at the top of the hour and data is already loaded.
    return

replaceRates: (data) ->
  base_rates = data.rates

  for from_currency in @from_currencies
    from_rate = base_rates[from_currency]
    to_rate = base_rates[@to_currency]

    if from_rate and to_rate
      # Calculate the exchange rate.
      rate = to_rate / from_rate
      $domEl = $("#widget-#{from_currency}-#{@to_currency}")
      $domEl.find("#rate-#{from_currency}-#{@to_currency}").html(rate.toFixed(4))
    else
      $("#widget-#{from_currency}-#{@to_currency}").hide()

  currentTime = new Date()
  formattedTime = currentTime.getFullYear() + "-" +
                  String(currentTime.getMonth() + 1).padStart(2, '0') + "-" +
                  String(currentTime.getDate()).padStart(2, '0') + " " +
                  String(currentTime.getHours()).padStart(2, '0') + ":" +
                  String(currentTime.getMinutes()).padStart(2, '0') + ":" +
                  String(currentTime.getSeconds()).padStart(2, '0')

  $('#last-update').html("Last update: " + formattedTime)
