# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@Book = (() ->
  Chapter = (text) ->
    that = this

    @text = text
    @paragraphStartIndex = 0
    @paragraphEndIndex = 0
    @totalParagraphs = 0
    @paragraphs = []

    $(@text).each(() ->
      that.paragraphs.push(this) if $(this).html()
      that.totalParagraphs++
    )

    return

  Chapter.ids = []

  Chapter.all = []

  Chapter.currentIndex = 0

  Chapter.fetchRemaining = (val, skip) ->
    unless val >= Chapter.ids.length
      if val != skip
        $.getJSON(
          "/chapters/" + Chapter.ids[val] + ".json",
          (data) ->
            Chapter.all[val] = new Chapter(data.text)

            Chapter.fetchRemaining(val + 1, skip)
        )
      else
        Chapter.fetchRemaining(val + 1, skip)

    return

  Chapter.fetch = (callback) ->
    $.getJSON(
      "/chapters/" + Chapter.ids[Chapter.currentIndex] + ".json",
      (data) ->
        Chapter.all[Chapter.currentIndex] = new Chapter(data.text)

        skip = Chapter.currentIndex # captured incase the callback changes it

        callback() if callback

        Chapter.fetchRemaining(0, skip)
    )

    return

  Display = (element, bookId) ->
    that = this

    @element = element
    @bookId = bookId
    @chapterIds = null

    @loadBook = () ->
      key("right", () ->
        that.nextPage()
      )

      key("left", () ->
        that.previousPage()
      )

      $(window).resize(() ->
        that.currentPage()
      )

      that.fetchBook(that.nextPage)

    @fetchBook = (callback) ->
      $.getJSON(
        "/books/" + that.bookId + ".json",
        (data) ->
          that.chapterIds = data.chapter_ids
          Chapter.ids = data.chapter_ids
          Chapter.fetch(callback)
      )

    @currentPage = () ->
      that.element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      pIndex = currentChapter.paragraphStartIndex

      while true
        paragraph = currentChapter.paragraphs[pIndex]
        pIndex++

        that.element.append(paragraph)

        if that.element.height() > $("#backdrop").height() - 20
          paragraph.remove()
          currentChapter.paragraphEndIndex = pIndex - 1
          break

        if pIndex >= currentChapter.totalParagraphs
          currentChapter.paragraphEndIndex = currentChapter.totalParagraphs
          break

    @nextPage = () ->
      that.element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.paragraphEndIndex >= currentChapter.totalParagraphs
        Chapter.currentIndex++
        currentChapter = Chapter.all[Chapter.currentIndex]

      pIndex = currentChapter.paragraphEndIndex
      currentChapter.paragraphStartIndex = pIndex
      
      console.log("next")
      console.log(currentChapter)

      while true
        paragraph = currentChapter.paragraphs[pIndex]
        pIndex++

        that.element.append(paragraph)

        if that.element.height() > $("#backdrop").height() - 20
          paragraph.remove()
          currentChapter.paragraphEndIndex = pIndex - 1
          break

        if pIndex >= currentChapter.totalParagraphs
          currentChapter.paragraphEndIndex = currentChapter.totalParagraphs
          break

    @previousPage = () ->
      that.element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.paragraphStartIndex <= 0
        currentChapter.paragraphEndIndex = 0
        Chapter.currentIndex--
        return that.currentPage()
      
      currentChapter.paragraphEndIndex = currentChapter.paragraphStartIndex
      pIndex = currentChapter.paragraphStartIndex - 1

      console.log("previous")
      console.log(currentChapter)

      while true
        paragraph = currentChapter.paragraphs[pIndex]
        pIndex--

        that.element.prepend(paragraph)

        if pIndex < 0
          currentChapter.paragraphStartIndex = 0
          break
        
        if that.element.height() > $("#backdrop").height() - 20
          paragraph.remove()
          currentChapter.paragraphStartIndex = pIndex + 2
          break


    return

  return {
    Display: Display,
    Ch: Chapter.all
  }
)()