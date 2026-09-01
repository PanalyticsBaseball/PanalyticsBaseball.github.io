---
layout: page
title: Hitters
permalink: /player-analysis/hitters/
description: Hitter evaluations combining offensive performance, visual evidence, and player-development context.
nav: false
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-lead">Hitter evaluations built to connect offensive indicators with visual evidence, baseball context, and practical development questions.</p>

<div class="pb-grid pb-section">
  {% assign hitters = site.players | where: "player_type", "hitter" | sort: "order" %}
  {% for player in hitters %}
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
