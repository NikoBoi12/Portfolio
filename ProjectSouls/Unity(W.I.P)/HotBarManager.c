using System.Collections.Generic;
using TMPro;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

public class HotbarManager : MonoBehaviour
{
    private GameObject[] hotbarItems;
    private List<GameObject> hotBarUI = new List<GameObject>();
    public int SlotCount = 4;
   public GameObject panel;

    public GameObject this[int slot]
    {
        get
        {
            if (slot < 0 || slot >= SlotCount)
            {
                return null;
            }
            return hotbarItems[slot];
        }
        set
        {
            if (slot < 0 || slot >= SlotCount)
            {
                return;
            }

            if (hotbarItems[slot] != null && value != null)
            {
                return;
            }

            hotbarItems[slot] = value;
            hotBarUI[slot].GetComponent<UpdateText>().UpdateHotBarText(value);
        }
    }

    void Start()
    {
        hotbarItems = new GameObject[SlotCount];
        hotBarUI = UtilityFunctions.GetChildren(panel.transform);
        
        int i = 0;

        foreach (GameObject Panel in hotBarUI) {
            i++;
            TMP_Text textPanel = Panel.transform.GetChild(0).transform.gameObject.GetComponent<TMP_Text>();
            textPanel.text = "Default";
        }
    }
}
