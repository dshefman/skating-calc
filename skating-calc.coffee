couples = []
judges = []
dances = []
marks = []

$ ->
  $('h1').click ->
    $(this).hide 'slow'
  $('#coupleAdd').click ->
    addCouple()
  $('#coupleRemove').click ->
    removeCouple()
  $('#judgeAdd').click ->
    addJudge()
  $('#judgeRemove').click ->
    removeJudge()
  $('#danceAdd').click ->
    addDance()
  $('#danceRemove').click ->
    removeDance()
  $('#marksGen').click ->
    generateMarks()
  $('#interGen').click ->
    generateInter()

addCouple = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#coupleFields').append newDivContent

  couples.push {number: "", name: ""}

  thisIndex = couples.length - 1
  $('#coupleFields .numberInput').last().focusout ->
    couples[thisIndex].number = this.value
  $('#coupleFields .nameInput').last().focusout ->
    couples[thisIndex].name = this.value

removeCouple = ->
  return if couples.length < 1

  couples.pop()
  $('#coupleFields div:last').remove()

addJudge = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#judgeFields').append newDivContent

  judges.push {number: "", name: ""}

  thisIndex = judges.length - 1
  $('#judgeFields .numberInput').last().focusout ->
    judges[thisIndex].number = this.value
  $('#judgeFields .nameInput').last().focusout ->
    judges[thisIndex].name = this.value

removeJudge = ->
  return if judges.length < 1

  judges.pop()
  $('#judgeFields div:last').remove()

addDance = ->
  newDivContent = '<div><input type="text" class="numberInput">'
  newDivContent += '<input type="text" class="nameInput">'
  newDivContent += '<br /></div>'
  $('#danceFields').append newDivContent

  dances.push {number: "", name: ""}

  thisIndex = dances.length - 1
  $('#danceFields .numberInput').last().focusout ->
    dances[thisIndex].number = this.value
  $('#danceFields .nameInput').last().focusout ->
    dances[thisIndex].name = this.value

removeDance = ->
  return if dances.length < 1

  dances.pop()
  $('#danceFields div:last').remove()

generateMarks = ->
  return if couples.length < 1 or judges.length < 1 or dances.length < 1

  $('#marks').empty()
  marks = []

  for dance in dances
    marks.push []
    danceIdx = marks.length - 1
    newTable = '<div><h3>' + dance.name + '</h3>'
    newTable += '<table><tr><th></th>'
    for judge in judges
      newTable += '<th>' + judge.number + '</th>'
    newTable += '</tr>'
    for couple in couples
      marks[danceIdx].push []
      coupleIdx = marks[danceIdx].length - 1
      newTable += '<tr><td>' + couple.number + '</td>'
      for judge in judges
        marks[danceIdx][coupleIdx].push ""
        newTable += '<td><input type="text"></td>'
    newTable += '<br /></div>'
    $('#marks').append newTable


  $('#marks input').each (index) ->
    $(this).focusout ->
      judgeIdx = index % judges.length
      coupleIdx = (Math.floor(index / judges.length)) % couples.length
      danceIdx = Math.floor(index / (couples.length * judges.length))
      marks[danceIdx][coupleIdx][judgeIdx] = this.value

validateMarks = ->
  for dance, danceIdx in marks
    lastCouple = dance.length - 1
    lastJudge = dance[0].length - 1
    for judgeIdx in [0..lastJudge]
      markTracker = (false for i in [0..lastCouple])
      for coupleIdx in [0..lastCouple]
        mark = parseInt dance[coupleIdx][judgeIdx]
        if mark >= 1 and mark <= lastCouple+1
          markTracker[mark-1] = true
        else
          return false
      return false for m in markTracker when not m
  return true

generateInter = ->
  # Validate stuff
  return unless validateMarks()
  console.log 'validated'
