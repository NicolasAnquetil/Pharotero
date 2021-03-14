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
	"form the #data field of a JSON Zotero item, creates a PharoteroItem
	 instance variables #key, #itemType, #title, #url, #publisher are mapped directly to correponding JSON fields
	 instance variable #abstract is mapped to JSON field #abstractNote
	 instance variable #authors is mapped to JSON field #creators (a list of creators)
	    a JSON #creator has 3 fields: #firstName, #lastName, and #creatorType which should always be 'author', we ignore this last one and make a NeoJSONObject with the first 2 fields.
	    and the resulting list of NeoJSONObject is stored into instance variable #authors"
	mapper
		for: PharoteroItem do: [ :mapping | 
	      mapping mapInstVars: #(key itemType title url publisher date).
			mapping mapInstVar: #abstract to: #abstractNote.
			(mapping mapInstVar: #authors to: #creators)
				valueSchema: #listOfCreators.
		] ;
		for: #listOfCreators customDo: [ :mapping |
			mapping listOfElementSchema: NeoJSONObject .
		] ;
		for: NeoJSONObject do: [ :mapping |
				mapping mapAccessors: #(firstName lastName) ]
]

{ #category : #accessing }
PharoteroItem >> abstract [
	^ abstract
]

{ #category : #accessing }
PharoteroItem >> authors [
	^ authors
]

{ #category : #accessing }
PharoteroItem >> date [
	^ date
]

{ #category : #accessing }
PharoteroItem >> itemType [
	^ itemType
]

{ #category : #accessing }
PharoteroItem >> key [
	^ key
]

{ #category : #accessing }
PharoteroItem >> parentCollection [
	^ parentCollection
]

{ #category : #accessing }
PharoteroItem >> parentCollection: anObject [
	parentCollection := anObject
]

{ #category : #accessing }
PharoteroItem >> publisher [
	^ publisher
]

{ #category : #accessing }
PharoteroItem >> publisher: anObject [
	publisher := anObject
]

{ #category : #accessing }
PharoteroItem >> title [
	^ title
]

{ #category : #accessing }
PharoteroItem >> url [
	^ url
]
