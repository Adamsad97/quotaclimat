import random
import time
from prometheus_client import Counter, Gauge, Histogram, start_http_server

articles_analyzed = Counter("quotaclimat_articles_analyzed_total", "Total articles analyzed")
keywords_found = Counter("quotaclimat_keywords_found_total", "Total environmental keywords found", ["category"])
channels_active = Gauge("quotaclimat_channels_active", "Number of active channels being monitored")
processing_latency = Histogram(
    "quotaclimat_processing_seconds",
    "Time spent processing an article",
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0]
)

channels_active.set(34)

if __name__ == "__main__":
    start_http_server(8000)
    print("Prometheus /metrics server started on :8000")
    
    categories = ["climat", "biodiversite", "energie", "pollution"]

    while True:
        with processing_latency.time():
            time.sleep(random.uniform(0.1, 1.5))
            
            articles_analyzed.inc(random.randint(1, 5))
            
            if random.random() > 0.3:
                cat = random.choice(categories)
                keywords_found.labels(category=cat).inc(random.randint(1, 3))
