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
if [ -z "$frequency" ] && [ -n "${QUERY_STRING:-}" ]; then
  frequency="$(printf '%s' "$QUERY_STRING" | sed -n 's/^.*frequency=\([^&]*\).*$/\1/p')"
fi
frequency="$(urldecode "$frequency")"
json_response=false
case "${HTTP_ACCEPT:-}" in
  *application/json*) json_response=true ;;
esac

display_frequency="108.00"
if /usr/bin/radio-set-frequency "$frequency" >/tmp/radio-cgi.log 2>&1; then
  status="Frequency changed to ${frequency} MHz"
  display_frequency="$frequency"
  ok=true
else
  status="Frequency change failed"
  ok=false
fi

if [ "$json_response" = true ]; then
  printf 'Content-Type: application/json\r\n\r\n'
  printf '{"ok":%s,"frequency":"%s","message":"%s"}\n' "$ok" "$display_frequency" "$status"
  exit 0
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
      <p id="status" class="status">${status}</p>
      <form method="get" action="/cgi-bin/set-frequency.cgi">
        <label for="frequency">FM frequency</label>
        <output id="frequencyValue">${display_frequency} MHz</output>
        <input id="frequency" name="frequency" type="range" min="87.5" max="108.0" step="0.01" value="${display_frequency}">
        <div class="fine-grid" aria-label="Fine frequency adjustment">
          <button type="button" data-step="-1">-1</button>
          <button type="button" data-step="-0.1">-0.1</button>
          <button type="button" data-step="-0.01">-0.01</button>
          <button type="button" data-step="0.01">+0.01</button>
          <button type="button" data-step="0.1">+0.1</button>
          <button type="button" data-step="1">+1</button>
        </div>
        <button type="submit">Change frequency</button>
      </form>
    </section>
  </main>
  <script>
    const slider = document.getElementById('frequency');
    const value = document.getElementById('frequencyValue');
    const status = document.getElementById('status');
    const clamp = (frequency) => Math.min(108, Math.max(87.5, frequency));
    const format = (frequency) => clamp(frequency).toFixed(2);
    const update = () => value.textContent = format(Number(slider.value)) + ' MHz';
    const setFrequency = async (frequency) => {
      const next = format(frequency);
      slider.value = next;
      update();
      status.textContent = 'Changing frequency...';
      const response = await fetch('/cgi-bin/set-frequency.cgi?frequency=' + encodeURIComponent(next), {
        method: 'GET',
        headers: {
          'Accept': 'application/json'
        }
      });
      const result = await response.json();
      status.textContent = result.message;
      if (result.ok) {
        slider.value = format(Number(result.frequency));
        update();
      }
    };
    slider.addEventListener('input', update);
    document.querySelectorAll('[data-step]').forEach((button) => {
      button.addEventListener('click', () => {
        setFrequency(Number(slider.value) + Number(button.dataset.step)).catch(() => {
          status.textContent = 'Frequency change failed';
        });
      });
    });
    update();
  </script>
</body>
</html>
HTML
