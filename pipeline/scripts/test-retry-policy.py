#!/usr/bin/env python3
"""Offline tests for the Postiz retry policy used by the n8n workflow."""

RETRYABLE = {429, 500, 502, 503, 504}
BACKOFF_SECONDS = (30, 120, 600)


def classify(status_code: int, previous_attempts: int) -> tuple[str, int, int]:
    attempts = previous_attempts + 1
    retryable = status_code in RETRYABLE
    if status_code == 200:
        return 'published', attempts, 0
    if not retryable:
        return 'dead_letter', attempts, 0
    if attempts >= 3:
        return 'dead_letter', attempts, BACKOFF_SECONDS[min(attempts - 1, 2)]
    return 'retry_queued', attempts, BACKOFF_SECONDS[min(attempts - 1, 2)]


cases = [
    (200, 0, ('published', 1, 0)),
    (429, 0, ('retry_queued', 1, 30)),
    (503, 1, ('retry_queued', 2, 120)),
    (503, 2, ('dead_letter', 3, 600)),
    (401, 0, ('dead_letter', 1, 0)),
]
for status, attempts, expected in cases:
    actual = classify(status, attempts)
    assert actual == expected, (status, attempts, actual, expected)
print(f'retry policy tests passed ({len(cases)} cases)')
