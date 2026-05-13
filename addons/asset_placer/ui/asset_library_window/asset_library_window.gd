@tool
class_name AssetLibraryWindow
extends Control

signal asset_selected(asset: AssetResource)

@onready var presenter: AssetLibraryPresenter = AssetLibraryPresenter.new()
@onready var folder_presenter: FolderPresenter = FolderPresenter.new()

@onready var placer_presenter := AssetPlacerPresenter.instance
@onready var grid_container: Container = %GridContainer
@onready var preview_resource = preload(
	"res://addons/asset_placer/ui/components/asset_resource_preview.tscn"
)
var assetPreviewPool:Array[AssetResourcePreview] = []
@onready var add_folder_button: Button = %AddFolderButton
@onready var search_field: LineEdit = %SearchField
@onready var filter_button: Button = %FilterButton
@onready var filters_label: Label = %FiltersLabel
@onready var reload_button: Button = %ReloadButton
@onready var sort_button: Button = %SortButton
@onready var ascending_order_button: Button = %AscendingOrderButton

@onready var progress_bar = %ProgressBar
@onready var empty_content = %EmptyContent
@onready var main_content = %MainContent
@onready var empty_collection_content = %EmptyCollectionContent
@onready var empty_collection_view_add_folder_btn: Button = %EmptyCollectionViewAddFolderBtn
@onready var scroll_container = %ScrollContainer
@onready var empty_search_content = %EmptySearchContent
@onready var empty_view_add_folder_btn = %EmptyViewAddFolderBtn
@onready var folder_filter_list: ItemList = %FolderFilterList

var readyToStart:bool = false
var didStart:bool = false

func _on_visibility_changed() -> void:
	if(readyToStart && !didStart && is_visible_in_tree()):
		didStart = true
		readyActually()

func _ready():
	readyToStart = true

func readyActually():
	if is_part_of_edited_scene():
		return

	folder_presenter.folders_loaded.connect(_show_folders)
	folder_presenter._ready()
	presenter.assets_loaded.connect(show_assets)
	presenter.show_filter_info.connect(show_filter_info)
	placer_presenter.asset_selected.connect(set_selected_asset)
	placer_presenter.asset_deselected.connect(clear_selected_asset)
	empty_collection_view_add_folder_btn.pressed.connect(show_folder_dialog)
	empty_view_add_folder_btn.pressed.connect(show_folder_dialog)
	presenter.show_empty_view.connect(show_empty_view)
	presenter.synchronizer.sync_state_change.connect(func(v): show_sync_in_progress(v))

	presenter.on_ready()

	for method in AssetSortBy.SortMethod.keys():
		sort_button.add_item(method.capitalize(), AssetSortBy.SortMethod[method])

	sort_button.selected = 0
	sort_button.item_selected.connect(presenter.on_sort_method_change)
	ascending_order_button.pressed.connect(flip_order)

	add_folder_button.pressed.connect(show_folder_dialog)
	search_field.text_changed.connect(presenter.on_query_change)
	reload_button.pressed.connect(presenter.sync)
	filter_button.pressed.connect(
		func():
			CollectionPicker.show_in(
				filter_button, presenter._active_collections, presenter.toggle_collection_filter
			)
	)

func putAssetPreviewIntoPool(_preview:AssetResourcePreview):
	# Remove signals
	_preview.left_clicked.disconnect(onAssetLeftClick)
	_preview.right_clicked.disconnect(onAssetRightClick.bind(_preview))
	# Remove from parent
	_preview.get_parent().remove_child(_preview)
	# Put into pool
	assetPreviewPool.append(_preview)

func show_assets(assets: Array[AssetResource]):
	placer_presenter.current_assets = assets
	empty_collection_content.hide()
	scroll_container.show()
	# Save way of putting nodes into the pool
	var gridChildAm:int = grid_container.get_child_count()
	for _i in gridChildAm:
		var _indx:int = gridChildAm - _i - 1
		var theNode:Node = grid_container.get_child(_indx)
		if(theNode is AssetResourcePreview):
			putAssetPreviewIntoPool(theNode)
		else:
			theNode.queue_free()
	#for child in grid_container.get_children():
	#	child.queue_free()
	for asset in assets:
		var child: AssetResourcePreview = preview_resource.instantiate() if assetPreviewPool.is_empty() else assetPreviewPool.pop_back()
		child.left_clicked.connect(onAssetLeftClick)
		child.right_clicked.connect(onAssetRightClick.bind(child))
		child.set_meta("id", asset.id)
		grid_container.add_child(child)
		child.set_asset(asset)

func onAssetLeftClick(_asset:AssetResource):
	if is_instance_valid(_asset.get_resource()):
		placer_presenter.toggle_asset(_asset)
	else:
		push_error("Invalid asset")

func onAssetRightClick(_asset:AssetResource, _child:AssetResourcePreview):
	show_asset_menu(_asset, _child)

func show_asset_menu(asset: AssetResource, _control: Control):
	var options_menu := PopupMenu.new()
	var mouse_pos = DisplayServer.mouse_get_position()
	options_menu.add_icon_item(EditorIconTexture2D.new("Groups"), "Manage collections")
	options_menu.add_icon_item(EditorIconTexture2D.new("File"), "Open")
	options_menu.add_icon_item(EditorIconTexture2D.new("Texture2D"), "Regenerate icon")
	options_menu.add_icon_item(EditorIconTexture2D.new("Remove"), "Remove")
	options_menu.index_pressed.connect(
		func(index):
			match index:
				0:
					ManageCollectionsDialog.open(asset.id)
				1:
					EditorInterface.open_scene_from_path(asset.get_path())
					EditorInterface.set_main_screen_editor("3D")
				2:
					var coordinator := ThumbnailGenerationCoordinator.instance
					if not is_instance_valid(coordinator):
						return false
					if coordinator.is_running():
						return false
					return coordinator.start_regeneration([asset], false)
				3:
					if placer_presenter._selected_asset == asset:
						placer_presenter.clear_selection()
					presenter.delete_asset(asset)
				_:
					pass
	)
	EditorInterface.popup_dialog(
		options_menu, Rect2(mouse_pos, options_menu.get_contents_minimum_size())
	)


func show_folder_dialog():
	var folder_dialog = EditorFileDialog.new()
	folder_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	folder_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	folder_dialog.dir_selected.connect(presenter.add_folder)
	EditorInterface.popup_dialog_centered(folder_dialog)


func clear_selected_asset():
	for child in grid_container.get_children():
		if child is Button:
			child.set_pressed_no_signal(false)


func _can_drop_data(_at_position, data):
	if data is Dictionary:
		var type = data["type"]
		var files_or_dirs = type == "files_and_dirs" || type == "files"
		return files_or_dirs and data.has("files")
	return false


func _drop_data(_at_position, data):
	var dirs: PackedStringArray = data["files"]
	presenter.add_assets_or_folders(dirs)


func show_filter_info(size: int):
	if size == 0:
		filters_label.hide()
	else:
		filters_label.show()
		filters_label.text = str(size)


func set_selected_asset(asset: AssetResource):
	for child in grid_container.get_children():
		if child is AssetResourcePreview:
			child.select_not_signal(child.get_meta("id") == asset.id)


func flip_order():
	ascending_order_button.scale.y *= -1
	var text := "Sort by %s order." % ("ascending" if presenter.is_sort_ascending else "descending")
	ascending_order_button.tooltip_text = text

	presenter.is_sort_ascending = not presenter.is_sort_ascending
	presenter._filter_by_collections_and_query()


func show_empty_view(type: AssetLibraryPresenter.EmptyType):
	match type:
		AssetLibraryPresenter.EmptyType.Search:
			show_empty_search_content()
		AssetLibraryPresenter.EmptyType.Collection:
			show_empty_collection_view()
		AssetLibraryPresenter.EmptyType.All:
			show_onboarding()
		AssetLibraryPresenter.EmptyType.None:
			show_main_content()


func show_main_content():
	main_content.show()
	empty_content.hide()
	scroll_container.show()
	empty_collection_content.hide()
	empty_search_content.hide()


func show_onboarding():
	main_content.hide()
	empty_collection_content.hide()
	empty_search_content.hide()
	empty_content.show()


func show_empty_collection_view():
	main_content.show()
	scroll_container.hide()
	empty_collection_content.hide()
	empty_collection_content.show()
	empty_content.hide()


func show_empty_search_content():
	main_content.show()
	scroll_container.hide()
	empty_collection_content.hide()
	empty_search_content.show()


func show_sync_in_progress(active: bool):
	if active:
		reload_button.hide()
		progress_bar.show()
	else:
		reload_button.show()
		progress_bar.hide()

func _show_folders(folders: Array[AssetFolder]):
	presenter.setActiveFolder(null)
	folder_filter_list.clear()

	folder_filter_list.add_item("All folders")
	for folder in folders:
		var theFolderSplit := folder.path.split("/", false)
		folder_filter_list.add_item(theFolderSplit[theFolderSplit.size()-1] if !theFolderSplit.is_empty() else "Empty name")
		#var instance: FolderView = folder_res.instantiate()
		#v_box_container.add_child(instance)
		#instance.set_folder(folder)

func _on_folder_filter_list_item_selected(_index: int) -> void:
	if(_index <= 0):
		presenter.setActiveFolder(null)
		return
	_index -= 1
	var lib := AssetLibraryManager.get_asset_library()
	var allTheFolders := lib.get_folders()
	if(_index < 0 || _index >= allTheFolders.size()):
		return
	presenter.setActiveFolder(allTheFolders[_index])
	
