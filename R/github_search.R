# Function to search for a term in an organization's issues and comments
search_org_issues_comments <- function(org_name, search_term, repo_name = NULL) {
  
  # Fetch repositories
  repos <- gh("GET /orgs/:org/repos", org = org_name)
  
  # Filter repositories based on the provided repo_name, if any
  if (!is.null(repo_name)) {
    repos <- Filter(function(x) x$name == repo_name, repos)
  }
  
  # Initialize a data frame to store the results
  search_df <- data.frame(Repo = character(), Issue_Title = character(), Issue_URL = character(), Sentence = character(), stringsAsFactors = FALSE)
  
  # Function to extract sentences containing the search term
  extract_sentences <- function(text, term) {
    if (!is.character(text)) {
      return(character(0))
    }
    
    sentences <- unlist(strsplit(text, "\\. "))
    matching_sentences <- grep(term, sentences, value = TRUE, ignore.case = TRUE)
    return(matching_sentences)
  }
  
  
  # Loop through the repositories
  for (repo in repos) {
    # Fetch open issues
    issues <- gh("GET /repos/:owner/:repo/issues", owner = org_name, repo = repo$name, state = "open")
    
    # Loop through the issues
    for (issue in issues) {
      # Search in issue title and body
      title_sentences <- extract_sentences(issue$title, search_term)
      body_sentences <- extract_sentences(issue$body, search_term)
      
      for (sentence in c(title_sentences, body_sentences)) {
        search_df <- rbind(search_df, data.frame(Repo = repo$name, Issue_Title = issue$title, Issue_URL = issue$html_url, Sentence = sentence, stringsAsFactors = FALSE))
      }
      
      # Fetch comments for the issue
      comments <- gh("GET /repos/:owner/:repo/issues/:number/comments", owner = org_name, repo = repo$name, number = issue$number)
      
      # Loop through the comments and search for the term
      for (comment in comments) {
        comment_sentences <- extract_sentences(comment$body, search_term)
        
        for (sentence in comment_sentences) {
          search_df <- rbind(search_df, data.frame(Repo = repo$name, Issue_Title = issue$title, Issue_URL = issue$html_url, Sentence = sentence, stringsAsFactors = FALSE))
        }
      }
    }
  }
  
  # Print the table using gt
  search_df %>%
    gt() %>%
    fmt_markdown(columns = c(Issue_URL))
}

# Example usage:
search_org_issues_comments("socialresearchcentre", "multi_batch")
