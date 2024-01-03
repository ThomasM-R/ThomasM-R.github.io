// load projects
fetch("projects.json")
	.then(res => res.json())
	.then(projects => {
	for (let project of projects) {

		
		
		
		document.querySelector("#projects-container").innerHTML += `				<div class="container">
	<div class="project window glass">
		<a href="${project.link}">${project.title}</a><br>
		${project.desc}
	</div>
</div>`;
	}
});