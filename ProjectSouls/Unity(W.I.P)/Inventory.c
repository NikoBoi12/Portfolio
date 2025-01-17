using System;
using System.Collections.Generic;
using System.ComponentModel;
using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.InputSystem;
using UnityEngine.UIElements;

public class Inventory : MonoBehaviour
{
    private int currentHotBarSlot = 0;
    public HotbarManager hotBarManager;


    // Start is called once before the first execution of Update after the MonoBehaviour is created

    public void activateItem(int previousSlot, int newHotbarSlot) {
        if (hotBarManager[previousSlot]) {
            Debug.Log("Deactivating item");
            hotBarManager[previousSlot].GetComponent<ItemProps>().item.SetActive(false);
        }
        if (hotBarManager[newHotbarSlot]) {
            hotBarManager[newHotbarSlot].GetComponent<ItemProps>().item.SetActive(true);
        }
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1)) {
            activateItem(currentHotBarSlot, 0);
            currentHotBarSlot = 0;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2)) {
            activateItem(currentHotBarSlot, 1);
            currentHotBarSlot = 1;
        }
        if (Input.GetKeyDown(KeyCode.Alpha3)) {
            activateItem(currentHotBarSlot, 2);
            currentHotBarSlot = 2;
        }
        if (Input.GetKeyDown(KeyCode.Alpha4)) {
            activateItem(currentHotBarSlot, 3);
            currentHotBarSlot = 3;
        }
    }
}
