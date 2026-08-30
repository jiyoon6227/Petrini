package com.petcare.petcare.search;

import java.util.List;

public class SearchSection {
    private final String label;
    private final List<SearchItem> items;

    public SearchSection(String label, List<SearchItem> items) {
        this.label = label;
        this.items = items;
    }

    public String getLabel() {
        return label;
    }

    public List<SearchItem> getItems() {
        return items;
    }
}
