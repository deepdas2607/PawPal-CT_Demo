"""
Tests for Health Check Endpoint.
"""

def test_health_check_returns_ok(client):
    """Verify that /health returns HTTP 200 and database connected."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["database"] == "connected"
    assert "version" in data

