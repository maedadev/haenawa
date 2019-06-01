json.extract!(@project, :id, :name)

json.scenarios(@project.scenarios, partial: 'scenarios/scenario', as: :scenario)
