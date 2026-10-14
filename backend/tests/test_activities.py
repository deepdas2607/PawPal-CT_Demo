"""
Tests for Care Activities Endpoints.
"""

def test_create_and_list_activities(client):
    """Creating an activity associates it with the pet and returns it in list."""
    pet_res = client.post("/api/pets", json={"name": "Rocky", "species": "Dog"})
    pet_id = pet_res.json()["id"]

    act_payload = {
        "activity_type": "Walking",
        "timestamp": "2026-10-14T08:30:00Z",
        "duration_minutes": 30,
        "notes": "Morning walk in the neighborhood park."
    }
    create_act = client.post(f"/api/pets/{pet_id}/activities", json=act_payload)
    assert create_act.status_code == 201
    act_data = create_act.json()
    assert act_data["activity_type"] == "Walking"
    assert act_data["pet_id"] == pet_id
    assert act_data["duration_minutes"] == 30

    # List activities
    list_act = client.get(f"/api/pets/{pet_id}/activities")
    assert list_act.status_code == 200
    activities = list_act.json()
    assert len(activities) == 1
    assert activities[0]["id"] == act_data["id"]

def test_create_activity_for_nonexistent_pet(client):
    """Logging activity for an invalid pet ID returns 404."""
    response = client.post("/api/pets/fake-pet-id/activities", json={
        "activity_type": "Feeding",
        "timestamp": "2026-10-14T09:00:00Z"
    })
    assert response.status_code == 404

