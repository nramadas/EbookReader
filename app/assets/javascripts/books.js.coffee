# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@Book = (() ->
  Chapter = (text, prev, parStart, parEnd) ->
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

    if prev == -1 # this chapter is before the current one
      that.paragraphStartIndex = that.totalParagraphs - 1
    else if prev == 0 # this chapter is the current one
      that.paragraphStartIndex = parStart
      that.paragraphEndIndex = parEnd

    return

  Chapter.ids = []

  Chapter.all = []

  Chapter.currentIndex = 3

  Chapter.fetchRemaining = (val, skip) ->
    unless val >= Chapter.ids.length
      if val != skip
        $.getJSON(
          "/chapters/" + Chapter.ids[val] + ".json",
          (data) ->
            prev = if (val < skip) then -1 else 1

            Chapter.all[val] = new Chapter(data.text, prev)

            Chapter.fetchRemaining(val + 1, skip)
        )
      else
        Chapter.fetchRemaining(val + 1, skip)

    return

  Chapter.fetch = (currentChapter, parStart, parEnd, callback) ->
    $.getJSON(
      "/chapters/" + Chapter.ids[Chapter.currentIndex] + ".json",
      (data) ->
        Chapter.all[Chapter.currentIndex] = new Chapter(data.text, 0,
                                                        parStart, parEnd)

        skip = Chapter.currentIndex # captured incase the callback changes it

        callback() if callback

        Chapter.fetchRemaining(0, skip)
    )

    return

  Display = (element, bookId, ownershipId, currentChapter, parStart, parEnd) ->
    that = this

    @element = element
    @bookId = bookId
    @ownershipId = ownershipId
    @chapterIds = null
    @parStart = parStart
    @parEnd = parEnd

    @bindKeys = () ->
      key("right", () ->
        that.nextPage()
      )

      key("left", () ->
        that.previousPage()
      )

    @bindClicks = () ->
      $("#next").click(()->
        that.nextPage()
      )

      $("#prev").click(()->
        that.previousPage()
      )

      $("#back").click(()->
        $(location).attr('href','/')
      )

    @loadBook = () =>
      Chapter.currentIndex = currentChapter

      @bindKeys()
      @bindClicks()

      $(window).resize(() ->
        that.printPage()
      )

      that.fetchBook(that.printPage)

    @saveState = () ->
      currentChapter = Chapter.all[Chapter.currentIndex]

      $.ajax({
        url: "/book_ownerships/" + that.ownershipId,
        type: "PUT",
        data: "current_chapter=" + Chapter.currentIndex +
              "&start_paragraph=" + currentChapter.paragraphStartIndex +
              "&end_paragraph=" + currentChapter.paragraphEndIndex
      })

    @fetchBook = (callback) ->
      $.getJSON(
        "/books/" + that.bookId + ".json",
        (data) ->
          that.chapterIds = data.chapter_ids
          Chapter.ids = data.chapter_ids
          Chapter.fetch(that.currentChapter, that.parStart,
                        that.parEnd, callback)
      )

    @printPage = (inChapter) =>
      @element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.paragraphEndIndex >= currentChapter.paragraphStartIndex
        pIndex = currentChapter.paragraphStartIndex
        currentChapter.paragraphStartIndex = pIndex

        while true
          paragraph = currentChapter.paragraphs[pIndex]
          pIndex++

          @element.append(paragraph)

          if @element.height() > $("#backdrop").height() - 50
            paragraph.remove()
            currentChapter.paragraphEndIndex = pIndex - 1
            break

          if pIndex >= currentChapter.totalParagraphs
            currentChapter.paragraphEndIndex = currentChapter.totalParagraphs
            break

      else
        console.log(Chapter.currentIndex)

        currentChapter.paragraphEndIndex = currentChapter.paragraphStartIndex
        pIndex = currentChapter.paragraphStartIndex - 1

        while true
          paragraph = currentChapter.paragraphs[pIndex]
          pIndex--

          @element.prepend(paragraph)

          if pIndex < 0
            currentChapter.paragraphStartIndex = 0
            break
          
          if @element.height() > $("#backdrop").height() - 50
            paragraph.remove()
            currentChapter.paragraphStartIndex = pIndex + 2
            break

      @saveState()

    @nextPage = () =>
      @element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.paragraphEndIndex >= currentChapter.totalParagraphs
        unless Chapter.currentIndex == Chapter.all.length - 1
          Chapter.currentIndex++

        currentChapter = Chapter.all[Chapter.currentIndex]

      currentChapter.paragraphStartIndex = currentChapter.paragraphEndIndex

      @printPage()

    @previousPage = () =>
      @element.empty()

      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.paragraphStartIndex <= 0
        currentChapter.paragraphEndIndex = 0
        if Chapter.currentIndex > 0
          Chapter.currentIndex--

        return @printPage()
      
      currentChapter.paragraphEndIndex = currentChapter.paragraphStartIndex - 1

      @printPage()

    return

  return {
    Display: Display
  }
)()