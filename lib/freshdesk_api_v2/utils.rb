module FreshdeskApiV2
  module Utils
    INTEGER_MAX = 2_147_483_647
    PAGE_REGEX = /.*[\?\&]page=(\d)*.*/
    MAX_SEARCH_RESULTS_PER_PAGE = 30.0
    MAX_SEARCH_PAGES = 10
    DEFAULT_PAGE = 1
    MAX_PAGE_SIZE = 100
    MAX_PAGE_SIZE_SEARCH = 30
  end
end
