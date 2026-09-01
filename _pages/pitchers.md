---
layout: page
title: Pitchers
permalink: /player-analysis/pitchers/
description: Pitcher evaluations combining arsenal characteristics, results, and player-development context.
nav: false
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-lead">Pitcher evaluations organized around arsenal characteristics, performance indicators, visual analysis, and development implications.</p>

<div class="pb-grid pb-section">
  {% assign pitchers = site.players | where: "player_type", "pitcher" | sort: "order" %}
  {% for player in pitchers %}
    <article class="pb-card">
      <img class="pb-card-image" src="{{ player.image | relative_url }}" alt="Placeholder image for {{ player.title }}">
      <div class="pb-card-body">
        <h3>{{ player.title }}</h3>
        <p class="pb-meta">{{ player.team }} · {{ player.position }}</p>
        <ul class="pb-metrics">{% for metric in player.metrics %}<li>{{ metric }}</li>{% endfor %}</ul>
        <p>{{ player.summary }}</p>
        <a class="pb-button" href="{{ player.url | relative_url }}">View Analysis</a>
      </div>
    </article>
  {% endfor %}
</div>
