document.addEventListener("DOMContentLoaded", function() {
    function adjustPopupSize() {
      var popupContent = document.getElementById("popup-content");
      var popupWidth = popupContent.offsetWidth;
      var popupHeight = popupContent.offsetHeight;
      var popupMaxHeight = window.innerHeight * 0.7; // Set maximum height to 70% of the screen height
      var calculatedHeight = Math.min(popupWidth * 1.5, popupMaxHeight) + "px"; // Adjust the scale factor as needed
  
      popupContent.style.height = calculatedHeight;
    }
  
    function adjustImageSize() {
      var popupImage = document.getElementById("popup-image");
      if (popupImage) {
        popupImage.onload = function() {
          adjustPopupSize();
        };
      }
    }
  
    window.addEventListener("resize", adjustPopupSize);
  
    setTimeout(function() {
      adjustImageSize();
      document.getElementById("popup").style.display = "block";
      adjustPopupSize();
    }, 3000);
  
    document.getElementById("close-button").addEventListener("click", function() {
      document.getElementById("popup").style.display = "none";
    });
  });