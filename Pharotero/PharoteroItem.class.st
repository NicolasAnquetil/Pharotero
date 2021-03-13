"
I represents a reference in a Zotero (http://www.zotero.org) library.


"
Class {
	#name : #PharoteroItem,
	#superclass : #Object,
	#instVars : [
		'key',
		'parentCollection',
		'itemType',
		'title',
		'authors',
		'abstract',
		'date',
		'url',
		'publisher'
	],
	#category : #'Pharotero-entities'
}

{ #category : #accessing }
PharoteroItem class >> neoJsonMapping: mapper [
	"key parentCollection itemType title authors abstract date url publisher"
	mapper
		for: PharoteroItem do: [ :mapping | 
	      mapping mapInstVars: #(key itemType title url publisher).
			mapping mapInstVar: #abstract to: #abstractNote.
			mapping mapAccessor: #jsonAutors to: #creators
		].

	"
	(mapping mapInstVar: #name to: #data)
		valueSchema: #dataName.
	mapper
		for: #dataName customDo: [ :mapping |
			mapping decoder: [ :dict | dict at: #name ]
		]"

]
