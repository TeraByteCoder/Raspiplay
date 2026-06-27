#!/bin/bash

read_post_data() {
  length="${CONTENT_LENGTH:-0}"
  if [ "$length" -gt 0 ] 2>/dev/null; then
    dd bs=1 count="$length" 2>/dev/null
  fi
}

urldecode() {
  local data="${1//+/ }"
  printf '%b' "${data//%/\\x}"
}

body="$(read_post_data)"
frequency="$(printf '%s' "$body" | sed -n 's/^.*frequency=\([^&]*\).*$/\1/p')"
frequency="$(urldecode "$frequency")"

display_frequency="108.0"
if /usr/bin/radio-set-frequency "$frequency" >/tmp/radio-cgi.log 2>&1; then
  status="Frequency changed to ${frequency} MHz"
  display_frequency="$frequency"
else
  status="Invalid frequency"
fi

cat <<HTML
Content-Type: text/html

<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Radio Configuration</title>
  <link rel="stylesheet" href="/assets/style.css">
</head>
<body>
  <main class="shell">
    <section class="panel">
      <h1>Radio-Sender</h1>
      <p>${status}</p>
      <form method="post" action="/cgi-bin/set-frequency.cgi">
        <label for="frequency">FM frequency</label>
        <output id="frequencyValue">${display_frequency} MHz</output>
        <input id="frequency" name="frequency" type="range" min="87.5" max="108.0" step="0.1" value="${display_frequency}">
        <button type="submit">Change frequency</button>
      </form>
    </section>
  </main>
  <script>
    const slider = document.getElementById('frequency');
    const value = document.getElementById('frequencyValue');
    const update = () => value.textContent = Number(slider.value).toFixed(1) + ' MHz';
    slider.addEventListener('input', update);
    update();
  </script>
</body>
</html>
HTML
