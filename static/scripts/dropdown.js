"use strict;"

function toggle_dropdown(button) {
	let content = button.parentNode.getElementsByClassName("dropdown-content")[0];
	let show = content.classList.contains("show");
	close_all_dropdown();
	if (!show) content.classList.add("show");
}

function close_all_dropdown() {
	let dropdowns = document.getElementsByClassName("dropdown");
	for (i = 0; i < dropdowns.length; i++) {
		dropdowns[i].getElementsByClassName("dropdown-content")[0].classList.remove("show");
	}
	//IE 11
	// for (x of document.getElementsByClassName("dropdown")) {
		// x.getElementsByClassName("dropdown-content")[0].classList.remove("show");
	// };
}

window.onclick = function(event) {
	if (event.target.matches(".dropdown *")) return;
	close_all_dropdown();
};
