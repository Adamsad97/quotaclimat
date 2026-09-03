"""Serveur Prometheus /metrics – QuotaClimat (Partie 2 de la consigne).

Expose sur le port 8000 :
  - Les métriques système par défaut de prometheus_client
    (process CPU, mémoire RSS, garbage collector, nombre de threads…)
  - Des métriques MÉTIER propres à QuotaClimat :
      quotaclimat_articles_analyzed_total  : nb d'articles traités
      quotaclimat_keywords_found_total     : nb de mots-clés détectés
      quotaclimat_channels_active          : nb de chaînes actives (gauge)
      quotaclimat_processing_seconds       : histogramme des durées de traitement
"""
import random
import time

from prometheus_client import (
    Counter,
    Gauge,
    Histogram,
    start_http_server,
)

# ── Métriques système (exposées automatiquement par prometheus_client) ──────
# process_cpu_seconds_total, process_resident_memory_bytes,
# python_gc_collections_total, python_info, etc.

# ── Métriques métier QuotaClimat ────────────────────────────────────────────
articles_analyzed = Counter(
    "quotaclimat_articles_analyzed_total",
    "Nombre total d'articles/sous-titres analysés depuis le démarrage",
    ["source"],          # label : 'tv', 'radio', 'press'
)

keywords_found = Counter(
    "quotaclimat_keywords_found_total",
    "Nombre total de mots-clés environnementaux détectés",
    ["theme"],           # label : 'changement_climatique', 'biodiversite', etc.
)

channels_active = Gauge(
    "quotaclimat_channels_active",
    "Nombre de chaînes médias actuellement surveillées",
)

processing_time = Histogram(
    "quotaclimat_processing_seconds",
    "Durée de traitement d'un lot d'articles (secondes)",
    buckets=[0.1, 0.25, 0.5, 1.0, 2.5, 5.0, 10.0],
)

heartbeat = Counter(
    "quotaclimat_heartbeat_total",
    "Battements depuis le démarrage (1 toutes les 5 s)",
)

# ── Simulation de trafic réaliste pour la démo ──────────────────────────────
SOURCES = ["tv", "radio", "press"]
THEMES  = [
    "changement_climatique",
    "biodiversite",
    "energie_renouvelable",
    "pollution",
    "adaptation_climatique",
]


def _simulate_processing_cycle() -> None:
    """Simule un cycle de traitement de médias (pour la démo Grafana)."""
    source = random.choice(SOURCES)
    batch_size = random.randint(5, 30)

    with processing_time.time():
        time.sleep(random.uniform(0.05, 0.3))   # durée réaliste de traitement

    articles_analyzed.labels(source=source).inc(batch_size)

    nb_keywords = random.randint(0, batch_size // 2)
    for _ in range(nb_keywords):
        theme = random.choice(THEMES)
        keywords_found.labels(theme=theme).inc()

    # Le nombre de chaînes fluctue légèrement (simule des déconnexions/reconnexions)
    channels_active.set(random.randint(18, 24))


if __name__ == "__main__":
    # Initialise les gauges avec des valeurs de départ réalistes
    channels_active.set(22)

    start_http_server(8000)
    print("Prometheus /metrics server started on :8000")

    while True:
        heartbeat.inc()
        _simulate_processing_cycle()
        time.sleep(5)
