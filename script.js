// load projects
fetch("projects.json")
	.then(res => res.json())
	.then(projects => {
	for (let project of projects) {
		container = document.createElement("div");
		container.classList.add("container");
		projectContainer = document.createElement("div");
		projectContainer.classList.add("project");
		projectContainer.style.backgroundImage = "url(" + project.thumb + ")";
		floppy = document.createElement("div");
		floppy.title = project.title;
		floppy.addEventListener("click", () => {
			document.getElementById("project-info").innerText = project.desc;
			document.getElementById("project-title").innerText = project.title;
			document.getElementById("project-link").innerText = "Check it out!"
			document.getElementById("project-link").href = project.link;
			location = "#projects";
		});
		floppy.addEventListener("dblclick", () => {
			window.open(project.link, "_blank");
		});
		projectContainer.appendChild(floppy);
		container.appendChild(projectContainer);
		document.getElementById("projects-container").appendChild(container);
	}
});