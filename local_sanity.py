def run_commands_from_workflow(file_path):
    # Load the YAML file
    with open(file_path, 'r') as f:
        workflow = yaml.load(f, Loader=yaml.FullLoader)
    
    # Get the list of jobs and their steps
    jobs = workflow.get('jobs', {})
    
    for job_name, job_details in jobs.items():
        steps = job_details.get('steps', [])
        
        for step in steps:
            # Check if 'uses' is present, as we might want to skip those actions
            if 'uses' in step:
                print(f"Skipping step: {step.get('name', 'Unnamed step')} with 'uses' action")
                continue

            # Extract the command from the 'run' field
            command = step.get('run')
            if command:
                # Replace single quotes with double quotes for Git Bash on Windows
                command = command.replace("'", '"')
                print(f"Running command: {command}")
                subprocess.run(command, shell=True)
               
