package com.learnos.contentlibrary.repository;

import com.learnos.contentlibrary.model.ContentLibraryItem;
import com.learnos.contentlibrary.model.ContentLibraryItemType;
import com.learnos.contentlibrary.model.ContentLibraryStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ContentLibraryRepository
        extends JpaRepository<ContentLibraryItem, UUID> {

    Page<ContentLibraryItem>
    findByCompany_IdAndStatus(
            UUID companyId,
            ContentLibraryStatus status,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByCompany_IdAndTypeAndStatus(
            UUID companyId,
            ContentLibraryItemType type,
            ContentLibraryStatus status,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByCompany_IdAndStatusAndTitleContainingIgnoreCase(
            UUID companyId,
            ContentLibraryStatus status,
            String query,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByCompany_IdAndTypeAndStatusAndTitleContainingIgnoreCase(
            UUID companyId,
            ContentLibraryItemType type,
            ContentLibraryStatus status,
            String query,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByStatus(
            ContentLibraryStatus status,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByTypeAndStatus(
            ContentLibraryItemType type,
            ContentLibraryStatus status,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByStatusAndTitleContainingIgnoreCase(
            ContentLibraryStatus status,
            String query,
            Pageable pageable
    );

    Page<ContentLibraryItem>
    findByTypeAndStatusAndTitleContainingIgnoreCase(
            ContentLibraryItemType type,
            ContentLibraryStatus status,
            String query,
            Pageable pageable
    );
}