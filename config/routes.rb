AcmProto::Application.routes.draw do

  resources :runs, only: ["index"] do
    collection do
      get "_jobs_table" # for ajax, datatables
    end
  end

  # Simulator-ParameterSet-Run relations
  simulator_actions = ["index", "show"]
  simulator_actions += ["new", "create", "edit", "update", "destroy"] unless OACIS_READ_ONLY
  resources :simulators, shallow: true, only: simulator_actions do
    collection do
      post "_sort" # for ajax, update order of the table
    end
    member do
      get 'duplicate' unless OACIS_READ_ONLY
      get 'explore'
      post "_make_query" # for ajax
      get "_parameters_list" # for ajax, datatables
      get "_analyzer_list" # for ajax, datatables
      get "_progress" # for progress table
    end

    parameter_set_actions = ["show"]
    parameter_set_actions += ["new", "create", "destroy"] unless OACIS_READ_ONLY
    resources :parameter_sets, only: parameter_set_actions do
      member do
        get 'duplicate' unless OACIS_READ_ONLY
        get "_runs_and_analyses" # for ajax, get
        get "_runs_list" # for ajax, datatables
        get "_analyses_list" # for ajax, datatables
        get "_similar_parameter_sets_list" # for ajax, datatables
        get "_line_plot" # for line plot
        get "_scatter_plot" # for scatter plot
        get "_figure_viewer" # for figure viewer
        get "_neighbor"
      end

      run_actions = ["show"]
      run_actions += ["create", "destroy"] unless OACIS_READ_ONLY
      analysis_actions = ["show"]
      analysis_actions += ["create", "destroy"] unless OACIS_READ_ONLY
      resources :runs, only: run_actions do
        member do
          get "_analyses_list" # for ajax, datatables
        end
        resources :analyses, only: analysis_actions do
          member do
            get "_result" # for ajax
          end
        end
      end
      resources :analyses, only: analysis_actions
    end

    analyzer_actions = ["show"]
    analyzer_actions += ["new", "create", "edit", "update", "destroy"] unless OACIS_READ_ONLY
    resources :analyzers, only: analyzer_actions do
      member do
        get '_parameters_form' # for ajax
        get "_inner_show" # for ajax, get
      end
    end
  end

  host_actions = ["index", "show"]
  host_actions += ["new", "create", "edit", "update", "destroy"] unless OACIS_READ_ONLY
  resources :hosts, only: host_actions do
    collection do
      post "_sort" # for ajax, update order of the table
    end
  end

  root :to => "simulators#index"
end
