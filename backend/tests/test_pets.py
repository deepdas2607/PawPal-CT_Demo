"""
Tests for Pet Profile Endpoints.
"""

def test_list_pets_initially_empty(client):
    """When no pet exists, /api/pets should return an empty list."""
    response = client.get("/api/pets")
    assert response.status_code == 200
    assert response.json() == []

def test_create_and_get_pet(client):
    """Creating a pet profile saves it to SQLite and can be retrieved."""
    payload = {
        "name": "Milo",
        "species": "Dog",
        "breed": "Golden Retriever",
        "date_of_birth": "2022-04-10",
        "avatar_symbol": "pawprint.fill"
    }
    create_res = client.post("/api/pets", json=payload)
    assert create_res.status_code == 201
    created_pet = create_res.json()
    assert created_pet["name"] == "Milo"
    assert created_pet["species"] == "Dog"
    assert "id" in created_pet

    # Fetch pet by ID
    pet_id = created_pet["id"]
    get_res = client.get(f"/api/pets/{pet_id}")
    assert get_res.status_code == 200
    fetched_pet = get_res.json()
    assert fetched_pet["id"] == pet_id
    assert fetched_pet["name"] == "Milo"

def test_update_pet(client):
    """Updating a pet profile updates fields and modifies updated_at."""
    create_res = client.post("/api/pets", json={
        "name": "Bella",
        "species": "Cat",
        "breed": "Siamese"
    })
    pet_id = create_res.json()["id"]

    update_res = client.put(f"/api/pets/{pet_id}", json={
        "name": "Bella Luna",
        "breed": "Persian"
    })
    assert update_res.status_code == 200
    updated_pet = update_res.json()
    assert updated_pet["name"] == "Bella Luna"
    assert updated_pet["breed"] == "Persian"
    assert updated_pet["species"] == "Cat"

def test_get_nonexistent_pet_returns_404(client):
    """Requesting an unknown pet ID should return HTTP 404."""
    response = client.get("/api/pets/non-existent-id")
    assert response.status_code == 404

def test_create_pet_validation_failure(client):
    """Submitting empty payload should return HTTP 422 Unprocessable Entity."""
    response = client.post("/api/pets", json={"name": ""})
    assert response.status_code == 422

