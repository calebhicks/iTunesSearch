# iTunesSearch

A simple demo of sample code for improving table view performance based off of the iTunesSearch lab project in Apple's App Development with Swift course.

## Discussion Notes

Goal: 60/120 FPS scrolling on a table view with images and dynamic data via a search from a REST API.

### Problem: Table view takes forever to display results

Why: Data is fetched, but table view is reloading on background thread.
Solution: Move `tableView.reloadData()` to the main thread.

### Problem: Choppy scrolling

Why: Image data for each cell is being fetched on the main thread, blocking scrolling until image data is loaded.
Solution: Fetch image data on a background thread.

### Problem: Images changing while scrolling

Why: Cells are getting reused, displaying the previous image until the new image loads.
Solution: Set the image to a blank image immediately to get rid of the wrong image.

### Problem: Cell displays the wrong image

You may not see this when working with small images. But if you're loading larger images, you may. Use HD artwork URL. 

(Semi consistent way to trigger: Search Pixar in Music, scroll to bottom, switch to Movies, tap status bar to quick scroll to top.)

Why: Cells are getting reused. The first image request finished after the later (correct) image request, and updated the image view accordingly.
Solution: Do not set the image if the cell has been reused.

Using the information available to us in the `configure` method, how can we tell if the cell has been reused?

### Problem: Images are slow to appear / data usage

Watch data usage when scrolling the list. We're going to put this on hard mode. Simulate slow network, or imagine limited data caps.

https://developer.apple.com/download/more/?q=Additional%20Tools

Why: Fetching the image for each cell every time it's displayed.
Solution: Cache the images either manually, or automatically.

When the server supports it, URL Cache will automatically cache responses up to a percentage of it's total memory/disk space. If you have 10MB of cache, it'll cache individual images whose size is up to ~5% of that. Otherwise, it won't. So smaller images are cached automatically, but larger images aren't. What can you do then? Increase the size of the cache.

### Problem: Still see too many grey squares

Why: The network request isn’t firing until the cell is configured and about to be displayed.
Solution: Launch the network request for the image before the cell is going to be displayed. The image will be cached, so when you run the network call again, the response will be immediate.

Steps:

* Add extension that conforms to prefetching
* For each index path, get the item and start a network request
* Set prefetching datasource in `viewDidLoad()`