---
layout: page
title: Scouting Reports
permalink: /scouting-reports/
description: Evidence-based amateur and international scouting reports combining performance, video, tool grades, context, and projection.
nav: true
nav_order: 4
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-lead">Evidence-based player evaluations combining verified performance, video observations, 20–80 tool grades, risk, and follow recommendations.</p>

<p class="pb-section-intro">These reports distinguish observed evidence from inference and projection. Grades are updated as stronger video, tracking data, and competitive context become available.</p>

<div class="pb-grid pb-grid-two pb-section">
  {% assign scouting_reports = site.players | where: "player_type", "scouting" | sort: "order" %}
  {% for player in scouting_reports %}
    <article class="pb-card">
      <img class="pb-card-image" src="{{ player.image | relative_url }}" alt="{{ player.title }} scouting report cover">
      <div class="pb-card-body">
        <p class="pb-eyebrow">{{ player.report_type }}</p>
        <h3>{{ player.title }}</h3>
        <p class="pb-meta">{{ player.team }} · {{ player.position }}</p>
        <ul class="pb-metrics">{% for metric in player.metrics %}<li>{{ metric }}</li>{% endfor %}</ul>
        <p>{{ player.summary }}</p>
        <a class="pb-button" href="{{ player.url | relative_url }}">View Scouting Report</a>
      </div>
    </article>
  {% endfor %}
</div>
