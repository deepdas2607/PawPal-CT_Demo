"""
Tests for Pet Care Tips and Favorites Endpoints.
"""

def test_fetch_tips_and_save_favorites(client):
    """Test fetching seeded tips, saving a tip for a pet, and unsaving."""
    # 1. Fetch seeded tips
    tips_res = client.get("/api/tips")
    assert tips_res.status_code == 200
    tips = tips_res.json()
    assert len(tips) >= 1
    tip_id = tips[0]["id"]

    # 2. Create Pet
    pet_res = client.post("/api/pets", json={"name": "Daisy", "species": "Dog"})
    pet_id = pet_res.json()["id"]

    # 3. Save Tip
    save_res = client.put(f"/api/pets/{pet_id}/saved-tips/{tip_id}")
    assert save_res.status_code == 200

    # 4. Fetch saved tips list
    saved_list_res = client.get(f"/api/pets/{pet_id}/saved-tips")
    assert saved_list_res.status_code == 200
    saved_ids = saved_list_res.json()
    assert tip_id in saved_ids

    # 5. Unsave Tip
    unsave_res = client.delete(f"/api/pets/{pet_id}/saved-tips/{tip_id}")
    assert unsave_res.status_code == 200

    # 6. Verify removed
    saved_after = client.get(f"/api/pets/{pet_id}/saved-tips").json()
    assert tip_id not in saved_after

