function listItems() {
  // Get the list element from the DOM.
  var listElement = document.getElementById("myList");

  // Create an array of items.
  var items = ["Item 1", "Item 2", "Item 3"];

  // Loop through the items array and add each item as a new list item.
  for (var i = 0; i < items.length; i++) {
    var liElement = document.createElement("li");
    liElement.textContent = items[i];
    listElement.appendChild(liElement);
  }
}

// Call the listItems() function when the page loads.
window.onload = listItems;
