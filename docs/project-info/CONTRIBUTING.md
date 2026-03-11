# Contributing to Agricultural Intelligence Platform

Thank you for your interest in contributing to the Agricultural Intelligence Platform! This project aims to empower farmers across East Africa with AI-powered agricultural insights.

## 🌟 How to Contribute

### Types of Contributions
- **Bug Reports**: Help us identify and fix issues
- **Feature Requests**: Suggest new features or improvements
- **Code Contributions**: Submit bug fixes or new features
- **Documentation**: Improve documentation and guides
- **Testing**: Help test the platform in different environments
- **Translations**: Add support for more local languages

## 🚀 Getting Started

### 1. Fork the Repository
```bash
# Fork the repo on GitHub, then clone your fork
git clone https://github.com/yourusername/AgriculturalIntelligencePlatform.git
cd AgriculturalIntelligencePlatform

# Add upstream remote
git remote add upstream https://github.com/original/AgriculturalIntelligencePlatform.git
```

### 2. Set Up Development Environment

#### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
pip install -r requirements-dev.txt

# Set up pre-commit hooks
pre-commit install
```

#### Mobile Setup
```bash
cd mobile
flutter pub get
flutter packages pub run build_runner build
```

#### Database Setup
```bash
# Start PostgreSQL with Docker
docker-compose up -d postgres redis

# Run migrations
cd backend
alembic upgrade head

# Load sample data
python scripts/load_sample_data.py
```

### 3. Create a Branch
```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or a bug fix branch
git checkout -b fix/issue-number-description
```

## 📝 Development Guidelines

### Code Style

#### Python (Backend)
- Follow PEP 8 style guide
- Use type hints for all functions
- Maximum line length: 88 characters (Black formatter)
- Use docstrings for all public functions and classes

```python
from typing import List, Optional
from pydantic import BaseModel

class UserResponse(BaseModel):
    """Response model for user data."""
    id: int
    email: str
    is_active: bool

async def get_user(user_id: int) -> Optional[UserResponse]:
    """
    Retrieve user by ID.
    
    Args:
        user_id: The ID of the user to retrieve
        
    Returns:
        User data if found, None otherwise
    """
    # Implementation here
    pass
```

#### Dart (Mobile)
- Follow Dart style guide
- Use meaningful variable and function names
- Add documentation comments for public APIs
- Use const constructors where possible

```dart
/// Service for handling disease detection
class DiseaseDetectionService {
  /// Detects disease from the provided image file
  /// 
  /// Returns a list of [DiseaseDetectionResult] with confidence scores
  Future<List<DiseaseDetectionResult>> detectDisease(File imageFile) async {
    // Implementation here
  }
}
```

### Commit Messages
Use conventional commit format:
```
type(scope): description

feat(auth): add two-factor authentication
fix(api): resolve database connection timeout
docs(readme): update installation instructions
test(disease): add unit tests for ML service
refactor(mobile): improve offline sync logic
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `chore`: Maintenance tasks

### Testing

#### Backend Testing
```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest tests/test_disease_detection.py

# Run tests with verbose output
pytest -v
```

#### Mobile Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run tests with coverage
flutter test --coverage
```

### Code Quality Tools

#### Backend
```bash
# Format code with Black
black app/ tests/

# Sort imports with isort
isort app/ tests/

# Lint with flake8
flake8 app/ tests/

# Type checking with mypy
mypy app/
```

#### Mobile
```bash
# Format code
dart format lib/ test/

# Analyze code
flutter analyze

# Check for unused dependencies
flutter pub deps
```

## 🐛 Reporting Bugs

### Before Submitting a Bug Report
1. Check if the bug has already been reported
2. Ensure you're using the latest version
3. Test with a clean environment

### Bug Report Template
```markdown
**Bug Description**
A clear description of the bug.

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected Behavior**
What you expected to happen.

**Actual Behavior**
What actually happened.

**Environment**
- OS: [e.g., Ubuntu 20.04, iOS 15]
- Flutter version: [e.g., 3.0.0]
- Python version: [e.g., 3.9.0]
- Device: [e.g., Samsung Galaxy A10]

**Screenshots**
If applicable, add screenshots.

**Additional Context**
Any other context about the problem.
```

## 💡 Feature Requests

### Feature Request Template
```markdown
**Feature Description**
A clear description of the feature you'd like to see.

**Problem Statement**
What problem does this feature solve?

**Proposed Solution**
How would you like this feature to work?

**Alternatives Considered**
Other solutions you've considered.

**Additional Context**
Any other context, mockups, or examples.

**Target Users**
Who would benefit from this feature?
```

## 🔄 Pull Request Process

### 1. Before Submitting
- Ensure all tests pass
- Update documentation if needed
- Add tests for new features
- Follow code style guidelines
- Update CHANGELOG.md if applicable

### 2. Pull Request Template
```markdown
**Description**
Brief description of changes.

**Type of Change**
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

**Testing**
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

**Checklist**
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or documented)

**Screenshots** (if applicable)
Add screenshots of UI changes.

**Related Issues**
Fixes #123
```

### 3. Review Process
1. Automated checks must pass
2. At least one maintainer review required
3. Address review feedback
4. Squash commits if requested
5. Maintainer will merge when approved

## 🌍 Internationalization

### Adding New Languages
1. Add locale to `mobile/lib/l10n/`
2. Create ARB file: `app_sw.arb` (for Swahili)
3. Translate all strings
4. Update `mobile/lib/l10n/l10n.dart`
5. Test with new locale

### Translation Guidelines
- Use clear, simple language
- Consider cultural context
- Test with native speakers
- Keep technical terms consistent
- Use appropriate formality level

## 📚 Documentation

### Types of Documentation
- **API Documentation**: OpenAPI/Swagger specs
- **User Guides**: How to use features
- **Developer Docs**: Technical implementation
- **Deployment Guides**: Setup and configuration

### Documentation Standards
- Use clear, concise language
- Include code examples
- Add screenshots for UI features
- Keep documentation up-to-date
- Test all examples

## 🧪 Testing Guidelines

### Test Categories
1. **Unit Tests**: Test individual functions/classes
2. **Integration Tests**: Test component interactions
3. **End-to-End Tests**: Test complete user workflows
4. **Performance Tests**: Test system performance
5. **Security Tests**: Test security measures

### Writing Good Tests
```python
# Good test example
def test_disease_detection_with_valid_image():
    """Test disease detection with a valid crop image."""
    # Arrange
    image_path = "tests/fixtures/diseased_leaf.jpg"
    expected_disease = "bacterial_blight"
    
    # Act
    result = detect_disease(image_path)
    
    # Assert
    assert result.disease_name == expected_disease
    assert result.confidence > 0.8
    assert len(result.recommendations) > 0
```

### Test Coverage
- Aim for >80% code coverage
- Focus on critical paths
- Test error conditions
- Mock external dependencies

## 🚀 Release Process

### Version Numbers
We use Semantic Versioning (SemVer):
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

### Release Checklist
1. Update version numbers
2. Update CHANGELOG.md
3. Run full test suite
4. Create release branch
5. Tag release
6. Deploy to staging
7. Test staging environment
8. Deploy to production
9. Monitor for issues

## 🤝 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Help others learn and grow
- Report inappropriate behavior

### Communication Channels
- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: General questions and ideas
- **Discord**: Real-time chat (link in README)
- **Email**: security@agriplatform.com (security issues)

### Getting Help
1. Check existing documentation
2. Search GitHub issues
3. Ask in GitHub Discussions
4. Join Discord community
5. Contact maintainers

## 🏆 Recognition

### Contributors
All contributors will be recognized in:
- README.md contributors section
- Release notes
- Annual contributor report

### Contribution Types
We recognize all types of contributions:
- Code contributions
- Bug reports
- Documentation improvements
- Testing and QA
- Community support
- Translations
- Design and UX

## 📋 Development Workflow

### 1. Planning
- Discuss major changes in issues first
- Break large features into smaller PRs
- Consider backward compatibility
- Plan for testing and documentation

### 2. Implementation
- Write tests first (TDD recommended)
- Implement feature/fix
- Update documentation
- Test thoroughly

### 3. Review
- Self-review your changes
- Submit PR with clear description
- Address review feedback promptly
- Be open to suggestions

### 4. Deployment
- Merge to main branch
- Automated deployment to staging
- Manual promotion to production
- Monitor for issues

## 🔒 Security

### Reporting Security Issues
- **DO NOT** create public issues for security vulnerabilities
- Email security@agriplatform.com
- Include detailed description and steps to reproduce
- We'll respond within 48 hours

### Security Best Practices
- Never commit secrets or API keys
- Use environment variables for configuration
- Validate all user inputs
- Use HTTPS for all communications
- Keep dependencies updated

## 📊 Performance

### Performance Guidelines
- Optimize database queries
- Use caching appropriately
- Minimize API calls
- Optimize images and assets
- Monitor performance metrics

### Mobile Performance
- Minimize app size
- Optimize for low-end devices
- Reduce battery usage
- Handle poor network conditions
- Cache data for offline use

## 🎯 Roadmap

### Current Focus
- Core disease detection features
- Weather integration
- Basic market data
- User authentication

### Upcoming Features
- Advanced ML models
- IoT sensor integration
- Blockchain supply chain
- Advanced analytics

### Long-term Vision
- Regional expansion
- Enterprise features
- Climate adaptation tools
- Carbon credit tracking

---

Thank you for contributing to the Agricultural Intelligence Platform! Together, we're building technology that empowers farmers and transforms agriculture in East Africa. 🌾💚

For questions about contributing, please reach out to the maintainers or join our community discussions.