function filterNav(q) {
    q = new RegExp(q, "i");
    [...document.querySelectorAll("body>nav>a.module")].forEach(e => {
        if (e.firstChild.textContent.trim().match(q)) e.hidden = false;
        else e.hidden = true;
    });
    [...document.querySelectorAll("body>nav>a.module-header")].forEach(e => {
        const add = e.textContent.trim().match(q);
        let e2 = e.nextElementSibling;
        while (e2 && e2.classList.contains("module")) {
        	if (add) e2.hidden = false;
            else if (e2.hidden == false) {
                e.hidden = false;
                return;
            }
            e2 = e2.nextElementSibling;
        }
        if (!add) e.hidden = true;
    });
    [...document.querySelectorAll("body>nav>a.module-group")].forEach(e => {
    	const add = e.textContent.trim().match(q);
        let e2 = e.nextElementSibling;
        while (e2 && (e2.classList.contains("module-header") || e2.classList.contains("module"))) {
        	if (add) e2.hidden = false;
            else if (e2.hidden == false) {
                e.hidden = false
                return;
            }
            e2 = e2.nextElementSibling;
        }
        if (!add) e.hidden = true
    });
}
function gotoFirst() {
    document.querySelector("body>nav>a.module:not([hidden])").click();
}