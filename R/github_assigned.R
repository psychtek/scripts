# Function to list organization repositories and their open issues assigned to a specific user
list_org_assigned_issues <- function(org_name, assignee = NULL, repo_name = NULL) {
  
  # Fetch repositories
  repos <- gh("GET /orgs/:org/repos", org = org_name)
  
  # Filter repositories based on the provided repo_name, if any
  if (!is.null(repo_name)) {
    repos <- Filter(function(x) x$name == repo_name, repos)
  }
  
  # Initialize a data frame to store the results
  issues_df <- data.frame(Repo = character(), Issue_Title = character(), Issue_URL = character(), Creator = character(), Comments = integer(), stringsAsFactors = FALSE)
  
  # Loop through the repositories
  for (repo in repos) {
    # Fetch open issues assigned to the specified user
    issues <- gh("GET /repos/:owner/:repo/issues", owner = org_name, repo = repo$name, state = "open", assignee = assignee)
    
    # Loop through the issues and add them to the data frame
    for (issue in issues) {
      issues_df <- rbind(issues_df, data.frame(Repo = repo$name, Issue_Title = issue$title, Issue_URL = issue$html_url, Creator = issue$user$login, Comments = issue$comments, stringsAsFactors = FALSE))
    }
  }
  
  # Print the table using gt
  issues_df %>%
    gt() %>%
    fmt_markdown(columns = c(Issue_URL)) %>%
    data_color(
      columns = c(Comments),
      fn = function(x) {
        scales::col_numeric(
          palette = c("red", "green"),
          domain = c(0, 5),
          na.color = "white"
        )(pmin(pmax(x, 0), 5))
      }
    ) |> 
    gtExtras::gt_theme_guardian()
}

# with table output -------------------------------------------------------

# Function to list organization repositories and their open issues assigned to a specific user
list_org_assigned_issues <- function(org_name, assignee = NULL, repo_name = NULL, print_console = FALSE) {
  
  # Fetch repositories
  repos <- gh("GET /orgs/:org/repos", org = org_name)
  
  # Filter repositories based on the provided repo_name, if any
  if (!is.null(repo_name)) {
    repos <- Filter(function(x) x$name == repo_name, repos)
  }
  
  # Initialize a data frame to store the results
  issues_df <- data.frame(Repo = character(), Issue_Title = character(), Issue_URL = character(), Creator = character(), Comments = integer(), stringsAsFactors = FALSE)
  
  # Loop through the repositories
  for (repo in repos) {
    # Fetch open issues assigned to the specified user
    issues <- gh("GET /repos/:owner/:repo/issues", owner = org_name, repo = repo$name, state = "open", assignee = assignee)
    
    # Loop through the issues and add them to the data frame
    for (issue in issues) {
      issues_df <- rbind(issues_df, data.frame(Repo = repo$name, Issue_Title = issue$title, Issue_URL = issue$html_url, Creator = issue$user$login, Comments = issue$comments, stringsAsFactors = FALSE))
    }
  }
  
  if (print_console) {
    # Print the table as a console-friendly table using huxtable
    library(huxtable)
    hux <- as_hux(issues_df)
    hux <- set_escape_contents(hux, 1:nrow(hux), "Issue_URL", FALSE)
    print_screen(hux)
  } else {
    # Print the table using gt
    issues_df %>%
      gt() %>%
      fmt_markdown(columns = c(Issue_URL)) %>%
      data_color(
        columns = c(Comments),
        fn = function(x) {
          scales::col_numeric(
            palette = c("red", "green"),
            domain = c(0, 5),
            na.color = "white"
          )(pmin(pmax(x, 0), 5))
        }
      ) |> 
      gtExtras::gt_theme_guardian()
  }
}


list_org_assigned_issues("socialresearchcentre", assignee = "psychtek", print_console = TRUE)
