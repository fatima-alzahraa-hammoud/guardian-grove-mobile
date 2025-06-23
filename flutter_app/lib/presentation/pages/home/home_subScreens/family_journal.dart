import 'package:flutter/material.dart';

class FamilyJournalScreen extends StatefulWidget {
  final bool collapsed;
  
  const FamilyJournalScreen({
    super.key, 
    this.collapsed = false,
  });

  @override
  State<FamilyJournalScreen> createState() => _FamilyJournalScreenState();
}

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String authorName;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.authorName,
  });
}

class _FamilyJournalScreenState extends State<FamilyJournalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Journal entries storage
  List<JournalEntry> _journalEntries = [];
  
  // Controllers for add entry dialog
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
    _loadSampleEntries(); // Load some sample entries
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _loadSampleEntries() {
    // Add some sample entries to demonstrate the functionality
    _journalEntries = [
      JournalEntry(
        id: '1',
        title: 'Family Beach Day',
        content: 'Had an amazing day at the beach today! The kids built sandcastles while we enjoyed the sunshine. Sarah found some beautiful shells and Tommy learned to swim without floaties!',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        authorName: 'Mom',
      ),
      JournalEntry(
        id: '2',
        title: 'First Day of School',
        content: 'Emma started kindergarten today. She was so brave and excited! She picked out her favorite dress and couldn\'t wait to meet her teacher. Proud parent moment! 📚',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        authorName: 'Dad',
      ),
    ];
  }

  void _addNewEntry() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: DateTime.now(),
      authorName: 'You', // You can get this from user storage
    );

    setState(() {
      _journalEntries.insert(0, newEntry); // Add to beginning of list
    });

    // Clear the controllers
    _titleController.clear();
    _contentController.clear();

    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Entry saved successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
                const Text(
                  'Family Journal',
                  style: TextStyle(
                    color: Color(0xFF1A202C),
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                // Journal icon
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFF0EA5E9),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - 100,
                ),
                padding: EdgeInsets.only(
                  top: 24, // pt-24 equivalent reduced for mobile
                  left: widget.collapsed ? 16 : 32,
                  right: widget.collapsed ? 16 : 32,
                  bottom: 24,
                ),
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: widget.collapsed ? 1152 : 1024, // max-w-6xl : max-w-5xl
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        _buildHeader(),
                        
                        SizedBox(
                          height: widget.collapsed ? 24 : 16, // mt-8 equivalent
                        ),
                        
                        // Content Area
                        _buildContentArea(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: widget.collapsed ? 32 : 28, // text-2xl : text-xl
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
              fontFamily: 'Comic Sans MS', // font-comic equivalent
              height: 1.2,
            ),
            child: const Text('Family Journal'),
          ),
          
          const SizedBox(height: 8), // mt-2
          
          // Subtitle
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: MediaQuery.of(context).size.width * (widget.collapsed ? 0.8 : 0.75),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: widget.collapsed ? 18 : 16, // text-lg : text-base
                color: const Color(0xFF6B7280), // text-gray-600
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
              child: const Text(
                'A place to capture your family\'s special moments, stories, and memories. Keep them close, cherish them forever.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Column(
        children: [
          // Placeholder content - you can add more journal content here
          _buildJournalPlaceholder(),
          
          SizedBox(height: widget.collapsed ? 24 : 16),
          
          // Add journal entry section
          _buildAddEntrySection(),
          
          SizedBox(height: widget.collapsed ? 24 : 16),
          
          // Recent entries section
          _buildRecentEntriesSection(),
        ],
      ),
    );
  }

  Widget _buildJournalPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 40,
              color: Color(0xFF0EA5E9),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start Your Family Journal',
            style: TextStyle(
              fontSize: widget.collapsed ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A202C),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Begin documenting your family\'s journey, special moments, and cherished memories.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.collapsed ? 16 : 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddEntrySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Entry',
                  style: TextStyle(
                    fontSize: widget.collapsed ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Capture today\'s special moments',
                  style: TextStyle(
                    fontSize: widget.collapsed ? 16 : 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // Handle add entry action
                _showAddEntryDialog();
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0EA5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Entries',
              style: TextStyle(
                fontSize: widget.collapsed ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A202C),
              ),
            ),
            if (_journalEntries.isNotEmpty)
              Text(
                '${_journalEntries.length} entries',
                style: TextStyle(
                  fontSize: widget.collapsed ? 14 : 12,
                  color: const Color(0xFF64748B),
                ),
              ),
          ],
        ),
        SizedBox(height: widget.collapsed ? 16 : 12),
        
        // Show entries or empty state
        _journalEntries.isEmpty 
          ? _buildEmptyState()
          : _buildEntriesList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: widget.collapsed ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your family memories will appear here',
            style: TextStyle(
              fontSize: widget.collapsed ? 14 : 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList() {
    return Column(
      children: _journalEntries.map((entry) => _buildEntryCard(entry)).toList(),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and date
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: widget.collapsed ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          entry.authorName,
                          style: TextStyle(
                            fontSize: widget.collapsed ? 14 : 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(entry.createdAt),
                          style: TextStyle(
                            fontSize: widget.collapsed ? 14 : 12,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu button
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                onPressed: () => _showEntryMenu(entry),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Content
          Text(
            entry.content,
            style: TextStyle(
              fontSize: widget.collapsed ? 16 : 14,
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Like',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.chat_bubble_outline,
                size: 18,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 8),
              Text(
                'Comment',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.share_outlined,
                size: 18,
                color: Colors.grey[400],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showEntryMenu(JournalEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF0EA5E9)),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                _editEntry(entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFEF4444)),
              title: const Text('Delete Entry'),
              onTap: () {
                Navigator.pop(context);
                _deleteEntry(entry);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Color(0xFF64748B)),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editEntry(JournalEntry entry) {
    _titleController.text = entry.title;
    _contentController.text = entry.content;
    
    showDialog(
      context: context,
      builder: (context) => _buildEntryDialog(isEditing: true, editingEntry: entry),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: Text('Are you sure you want to delete "${entry.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _journalEntries.removeWhere((e) => e.id == entry.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog() {
    _titleController.clear();
    _contentController.clear();
    
    showDialog(
      context: context,
      builder: (context) => _buildEntryDialog(),
    );
  }

  Widget _buildEntryDialog({bool isEditing = false, JournalEntry? editingEntry}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEditing ? Icons.edit_note_rounded : Icons.add_circle_outline,
                  color: const Color(0xFF0EA5E9),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditing ? 'Edit Journal Entry' : 'New Journal Entry',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Title field
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Entry Title',
                hintText: 'Give your memory a title...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                ),
                prefixIcon: const Icon(Icons.title, color: Color(0xFF64748B)),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            
            // Content field
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Share your memory...',
                hintText: 'Describe what happened, how you felt, or what made this moment special...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2),
                ),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _titleController.clear();
                      _contentController.clear();
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isEditing && editingEntry != null) {
                        _updateEntry(editingEntry);
                      } else {
                        _addNewEntry();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0EA5E9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      isEditing ? 'Update Entry' : 'Save Entry',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateEntry(JournalEntry originalEntry) {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in both title and content'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    setState(() {
      final index = _journalEntries.indexWhere((entry) => entry.id == originalEntry.id);
      if (index != -1) {
        _journalEntries[index] = JournalEntry(
          id: originalEntry.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          createdAt: originalEntry.createdAt, // Keep original date
          authorName: originalEntry.authorName,
        );
      }
    });

    _titleController.clear();
    _contentController.clear();
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Entry updated successfully!'),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }
}