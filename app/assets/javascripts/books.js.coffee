# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@Book = (() ->
  Chapter = (text, prev, parStart, parEnd, wordStart, wordEnd) ->
    that = this

    @startParagraph = 0
    @endParagraph = 0
    @startWord = 0
    @endWord = 0
    @paragraphIndex = 0
    @wordIndex = 0
    @totalParagraphs = 0
    @paragraphs = []

    $(text).each(() ->
      that.paragraphs.push(this) if $(this).html()
      that.totalParagraphs++
    )

    if prev == -1 # this chapter is before the current one
      that.paragraphIndex = that.totalParagraphs - 1
    else if prev == 0 # this chapter is the current one
      that.startParagraph = parStart
      that.endParagraph = parEnd
      that.paragraphIndex = parStart
      that.startWord = wordStart
      that.endWord = wordEnd
      that.wordIndex = wordStart

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
            prev = if (val < skip) then -1 else 1

            Chapter.all[val] = new Chapter(data.text, prev)

            Chapter.fetchRemaining(val + 1, skip)
        )
      else
        Chapter.fetchRemaining(val + 1, skip)

    return

  Chapter.fetch = (currentChapter, parStart, parEnd, wordStart, wordEnd, callback) ->
    $.getJSON(
      "/chapters/" + Chapter.ids[Chapter.currentIndex] + ".json",
      (data) ->
        Chapter.all[Chapter.currentIndex] = new Chapter(data.text, 0,
                                                        parStart, parEnd,
                                                        wordStart, wordEnd)

        skip = Chapter.currentIndex # captured incase the callback changes it

        callback() if callback

        Chapter.fetchRemaining(0, skip)
    )

    return

  Display = (element, bookId, ownershipId, currentChapter, parStart, parEnd, wordStart, wordEnd) ->
    that = this

    @element = element
    @bookId = bookId
    @ownershipId = ownershipId
    @chapterIds = null
    @parStart = parStart
    @parEnd = parEnd
    @wordStart = wordStart
    @wordEnd = wordEnd
    @timer = null

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

    @bindMouse = () ->
      $(document).mousemove(() ->
        window.clearTimeout(that.timer) if that.timer
        $("#back").children().fadeIn('slow', 'swing');
        $("#next").children().fadeIn('slow', 'swing');
        $("#prev").children().fadeIn('slow', 'swing');

        that.timer = window.setTimeout(() ->
          $("#back").children().fadeOut('slow', 'swing');
          $("#next").children().fadeOut('slow', 'swing');
          $("#prev").children().fadeOut('slow', 'swing');
        , 1000)
      )

    @loadBook = () =>
      Chapter.currentIndex = currentChapter

      @bindKeys()
      @bindClicks()
      @bindMouse()

      $(window).resize(() ->
        that.printPage('topdown')
      )

      that.fetchBook(that.printPage)

    @saveState = () ->
      currentChapter = Chapter.all[Chapter.currentIndex]

      $.ajax({
        url: "/book_ownerships/" + that.ownershipId,
        type: "PUT",
        data: "current_chapter=" + Chapter.currentIndex +
              "&start_paragraph=" + currentChapter.startParagraph +
              "&end_paragraph=" + currentChapter.endParagraph +
              "&start_word=" + currentChapter.startWord +
              "&end_word=" + currentChapter.endWord
      })

    @fetchBook = (callback) ->
      $.getJSON(
        "/books/" + that.bookId + ".json",
        (data) ->
          that.chapterIds = data.chapter_ids
          Chapter.ids = data.chapter_ids
          Chapter.fetch(that.currentChapter, that.parStart,
                        that.parEnd, that.wordStart, that.wordEnd, callback)
      )

    @getHeight = () =>
      totheight = 0

      @element.children().each(() ->
        totheight += $(this)[0].scrollHeight
      )

      return totheight

    @printWords = (currentChapter, paragraphIndex, wordIndex, direction) =>
      currentParagraph = currentChapter.paragraphs[paragraphIndex]
      words = $(currentParagraph).html().split(" ")
      wordParagraph = $(currentParagraph).clone().empty()
      wordParagraph.css("display", "inline")

      if direction == 'bottomup' && wordIndex == 0
        wordIndex = words.length - 1

      if direction == 'topdown'
        @element.append(wordParagraph)
      else
        @element.prepend(wordParagraph)

      while true
        word = words[wordIndex] + " "

        # Check if the word will fit:
        if direction == 'topdown'
          $("#wordarea").append(word)
        else
          $("#wordarea").prepend(word)

        wordWidth = $("#wordarea").width()
        wordHeight = $("#wordarea").height()

        if (@element.height() + wordHeight > $("#backdrop").height() - 60) &&
           (wordWidth > @element.width() - 40)
          currentChapter.wordIndex = wordIndex
          if direction != 'topdown'
            currentChapter.wordIndex++

          break
        else if wordIndex >= words.length && direction == 'topdown'
          currentChapter.wordIndex = 0
          currentChapter.paragraphIndex++
          break
        else if wordIndex < 0 && direction != 'topdown'
          currentChapter.wordIndex = 0
          currentChapter.paragraphIndex--
          break
        else
          beforeHeight = @element.height()
          if direction == 'topdown'
            wordParagraph.append(word)
            wordIndex++
          else
            wordParagraph.prepend(word)
            wordIndex--

          if @element.height() > beforeHeight
            $("#wordarea").empty()
            $("#wordarea").append(word)


    @printParagraphs = (currentChapter, paragraphIndex, wordIndex, direction) =>
      while true
        paragraph = currentChapter.paragraphs[paragraphIndex]

        if direction == 'topdown'
          @element.append(paragraph)
        else 
          @element.prepend(paragraph)

        if @element.height() > $("#backdrop").height() - 60
          paragraph.remove()
          @printWords(currentChapter, paragraphIndex, wordIndex, direction)
          currentChapter.paragraphIndex = paragraphIndex
          break
        else if paragraphIndex >= currentChapter.totalParagraphs &&
                direction == 'topdown'
          Chapter.currentIndex++
          currentChapter.paragraphIndex = paragraphIndex
          break
        else if paragraphIndex < 0 && direction != 'topdown'
          currentChapter.paragraphIndex = 0
          break
        else
          if direction == 'topdown'
            paragraphIndex++
          else
            paragraphIndex--

    @printPage = (direction) =>
      @element.empty()

      direction = 'topdown' unless direction

      currentChapter = Chapter.all[Chapter.currentIndex]

      if direction == 'topdown'
        currentChapter.startParagraph = currentChapter.paragraphIndex
        currentChapter.startWord = currentChapter.wordIndex
      else
        currentChapter.endParagraph = currentChapter.paragraphIndex
        currentChapter.endWord = currentChapter.wordIndex + 1

      if currentChapter.wordIndex != 0
        @printWords(currentChapter, currentChapter.paragraphIndex,
                    currentChapter.wordIndex, direction)

      @printParagraphs(currentChapter, currentChapter.paragraphIndex,
                       currentChapter.wordIndex, direction)

      if direction == 'topdown'
        currentChapter.endParagraph = currentChapter.paragraphIndex
        currentChapter.endWord = currentChapter.wordIndex
      else
        currentChapter.startParagraph = currentChapter.paragraphIndex
        currentChapter.startWord = currentChapter.wordIndex

      @saveState()

    @nextPage = () =>
      currentChapter = Chapter.all[Chapter.currentIndex]

      currentChapter.paragraphIndex = currentChapter.endParagraph
      currentChapter.wordIndex = currentChapter.endWord
      @printPage("topdown")

    @previousPage = () =>
      currentChapter = Chapter.all[Chapter.currentIndex]

      if currentChapter.startParagraph <= 0 && currentChapter.startWord <= 0
        Chapter.currentIndex--
        currentChapter = Chapter.all[Chapter.currentIndex]
        currentChapter.paragraphIndex = currentChapter.paragraphs.length
        currentChapter.wordIndex = 0
        @printPage("bottomup")
        Chapter.currentIndex++
        currentChapter = Chapter.all[Chapter.currentIndex]
        currentChapter.endParagraph = 0
        currentChapter.endWord = 0
      else
        if currentChapter.startWord == 0
          currentChapter.paragraphIndex = currentChapter.startParagraph - 1
          currentChapter.wordIndex = 0
        else
          currentChapter.paragraphIndex = currentChapter.startParagraph
          currentChapter.wordIndex = currentChapter.startWord - 1
        
        @printPage("bottomup")

    return

  return {
    Display: Display,
    Ch: Chapter.all
  }
)()