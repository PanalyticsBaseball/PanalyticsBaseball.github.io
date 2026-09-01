---
layout: page
title: Player Analysis
permalink: /player-analysis/
description: Data-driven player evaluation combining baseball context, advanced metrics, and visual analysis.
nav: true
nav_order: 3
dropdown: true
children:
  - title: Overview
    permalink: /player-analysis/
  - title: Hitters
    permalink: /player-analysis/hitters/
  - title: Pitchers
    permalink: /player-analysis/pitchers/
---

<link rel="stylesheet" href="{{ '/assets/css/panalytics.css' | relative_url }}">

<p class="pb-lead">Data-driven player evaluation combining baseball context, advanced metrics, and visual analysis.</p>

<p class="pb-section-intro">Each profile is structured to help a recruiter or baseball decision-maker understand the player, the evidence, and the practical Player Development or Scouting implications quickly.</p>

<section class="pb-section" aria-labelledby="featured-hitters">
  <h2 id="featured-hitters" class="pb-section-heading">Featured Hitters</h2>
  <div class="pb-grid">
    {% assign hitters = site.players | where: "player_type", "hitter" | sort: "order" %}
    {% for player in hitters %}
      <article class="pb-card">
        <img class="pb-card-image" src="{{ player.image | relative_url }}" alt="Placeholder image for {{ player.title }}">
        <div class="pb-card-body">
          <h3>{{ player.title }}</h3>
          <p class="pb-meta">{{ player.team }} · {{ player.position }}</p>
          <ul class="pb-metrics">
            {% for metric in player.metrics %}<li>{{ metric }}</li>{% endfor %}
          </ul>
          <p>{{ player.summary }}</p>
          <a class="pb-button" href="{{ player.url | relative_url }}">View Analysis</a>
        </div>
      </article>
    {% endfor %}
  </div>
</section>

<section class="pb-section" aria-labelledby="featured-pitchers">
  <h2 id="featured-pitchers" class="pb-section-heading">Featured Pitchers</h2>
  <div class="pb-grid">
    {% assign pitchers = site.players | where: "player_type", "pitcher" | sort: "order" %}
    {% for player in pitchers %}
      <article class="pb-card">
        <img class="pb-card-image" src="{{ player.image | relative_url }}" alt="Placeholder image for {{ player.title }}">
        <div class="pb-card-body">
          <h3>{{ player.title }}</h3>
          <p class="pb-meta">{{ player.team }} · {{ player.position }}</p>
          <ul class="pb-metrics">
            {% for metric in player.metrics %}<li>{{ metric }}</li>{% endfor %}
          </ul>
          <p>{{ player.summary }}</p>
          <a class="pb-button" href="{{ player.url | relative_url }}">View Analysis</a>
        </div>
      </article>
    {% endfor %}
  </div>
</section>

<p class="pb-placeholder"><strong>Placeholder policy:</strong> All six profiles are structural examples. Add real player names, teams, metrics, images, and original analysis only when the underlying work is ready.</p>
