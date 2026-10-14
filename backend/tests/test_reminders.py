"""
Tests for Care Reminders Endpoints.
"""

def test_reminder_lifecycle(client):
    """Test full lifecycle: create, list, mark complete, and delete."""
    # 1. Create Pet
    pet_res = client.post("/api/pets", json={"name": "Luna", "species": "Cat"})
    pet_id = pet_res.json()["id"]

    # 2. Create Reminder
    rem_payload = {
        "title": "Heartworm Medication",
        "notes": "Give 1 tablet with wet food.",
        "due_date": "2026-10-15T18:00:00Z"
    }
    create_res = client.post(f"/api/pets/{pet_id}/reminders", json=rem_payload)
    assert create_res.status_code == 201
    reminder = create_res.json()
    assert reminder["title"] == "Heartworm Medication"
    assert reminder["is_completed"] is False
    reminder_id = reminder["id"]

    # 3. List Reminders
    list_res = client.get(f"/api/pets/{pet_id}/reminders")
    assert list_res.status_code == 200
    reminders = list_res.json()
    assert len(reminders) == 1
    assert reminders[0]["id"] == reminder_id

    # 4. Mark Complete via PATCH
    patch_res = client.patch(f"/api/reminders/{reminder_id}", json={"is_completed": True})
    assert patch_res.status_code == 200
    updated_rem = patch_res.json()
    assert updated_rem["is_completed"] is True
    assert updated_rem["completed_at"] is not None

    # 5. Delete Reminder
    del_res = client.delete(f"/api/reminders/{reminder_id}")
    assert del_res.status_code == 200

    # 6. Verify removed from list
    list_after_del = client.get(f"/api/pets/{pet_id}/reminders")
    assert list_after_del.status_code == 200
    assert len(list_after_del.json()) == 0

def test_delete_nonexistent_reminder(client):
    """Deleting unknown reminder returns 404."""
    res = client.delete("/api/reminders/fake-reminder-id")
    assert res.status_code == 404

